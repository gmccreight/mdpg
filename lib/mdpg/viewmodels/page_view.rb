# frozen_string_literal: true

require 'redcarpet'

class PageView < Struct.new(:user, :page, :token_type)
  def name
    page.name
  end

  def add_tag(tag)
    user_page_tags.add_tag tag
  end

  def remove_tag(tag)
    user_page_tags.remove_tag tag
  end

  def should_show_locked_message?
    page_is_locked?
  end

  def page_is_locked?
    !!page.is_locked
  end

  def should_show_edit_button?
    return false if page_is_locked?
    token_type.nil? || token_type == :readwrite
  end

  def should_show_delete_button?
    !page_is_locked?
  end

  def tag_suggestions_for(partial_or_full_tag_name)
    all_tags = user_page_tags.search(partial_or_full_tag_name)
    all_tags - ObjectTags.new(page).sorted_tag_names
  end

  def fully_rendered_text
    text = text_before_markdown_parsing
    rendered_markdown text
  end

  def text_before_markdown_parsing
    text = PageLinks.new(user)
                    .internal_to_user_clickable_links(page.text)
    text = text_with_stylized_labeled_section_definitions(text, name)
    text = text_with_labeled_sections_transcluded(text)
    text
  end

  private def text_with_labeled_sections_transcluded(t)
    max_tries = 10
    trans = LabeledSectionTranscluder.new
    page_links = PageLinks.new(user)
    max_tries.times do
      before = t
      t = trans.transclude_sections(t) do |page, sec, sec_name, sec_id, opts|
        transcluded = page_links.internal_to_user_clickable_links(
          sec.text_for(sec_id)
        )

        if opts && opts.include?('short')
          link = "<a href='/p/#{page.name}##{sec_name}'>#</a>"
          "<span class='transcluded-short'>#{transcluded}</span>\n" \
          "(#{link})"
        elsif opts && opts.include?('no-headers')
          transcluded.gsub(/^[ ]{10}/, '')
        else
          "
          <div class='transcluded-section-header top-header'>
            <a href='/p/#{page.name}'>#{page.name}</a>##{sec_name}
          </div>

          #{transcluded}

          <div class='transcluded-section-header bottom-header'>&nbsp;</div>
          ".gsub(/^[ ]{10}/, '')
        end
      end
      if t == before
        break
      end
    end
    t
  end

  private def text_with_stylized_labeled_section_definitions(text, page_name)
    includers_info = LabeledSectionIncludersInfo.new(page).run
    already_processed_once = {}
    LabeledSectionParser.new(text).replace_target_with do |name, id, opts|
      page_ids = includers_info.select { |x| x[:section] == id }
                               .map { |x| x[:page_id] }
      page_names = page_ids.map { |x| Page.find(x).name }
      page_names_links = []
      page_names.each_with_index do |inc_name, index|
        l = %(<a href="/p/#{inc_name}")
        l += %( class="labeled-sec-inc-page">#{index + 1}</a>)
        page_names_links << l
      end
      page_names_links = page_names_links.join(' ')

      if opts.include?('only-includes')
        if already_processed_once.key?(id)
          %(<span>#{page_names_links}</span>)
        else
          already_processed_once[id] = true
          ''
        end
      else
        %(<span class="labeled-sec-wrap"> #{page_name}##{name}) +
          page_names_links +
         '</span>'
      end
    end
  end

  private def rendered_markdown(text)
    markdown = ::Redcarpet::Markdown.new(Redcarpet::Render::HTML,
      autolink: true, space_after_headers: true, tables: true)
    markdown.render text
  end

  private def page_tags
    ObjectTags.new(page)
  end

  private def user_page_tags
    UserPageTags.new(user, page)
  end
end
