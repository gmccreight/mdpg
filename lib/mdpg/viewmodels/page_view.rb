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

  def should_show_edit_button?
    token_type == nil || token_type == :readwrite
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
      .internal_links_to_user_clickable_links(page.text)
    text = text_with_stylized_labeled_section_definitions(text, name)
    text = text_with_labeled_sections_transcluded(text)
    text
  end

  private def text_with_labeled_sections_transcluded(text)
    text = LabeledSectionTranscluder.new.transclude_the_sections(text) do
        |page, section, section_name, section_identifier|
"
<div class='transcluded-section-header top-header'>
  <a href='/p/#{page.name}'>#{page.name}</a>##{section_name}
</div>

#{section.text_for(section_identifier)}

<div class='transcluded-section-header bottom-header'>
  &nbsp;
</div>
"
    end
    text
  end

  private def text_with_stylized_labeled_section_definitions(text, page_name)
    LabeledSectionParser.new(text).replace_definitions_with do |name|
      %Q(<span style="background-color:#ddd;"> #{page_name}##{name}) +
       '</span>'
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
