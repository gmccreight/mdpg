require 'redcarpet'

class PageView < Struct.new(:user, :page, :token_type)

  def name
    page.name
  end

  def add_tag tag
    user_page_tags().add_tag tag
  end

  def remove_tag tag
    user_page_tags().remove_tag tag
  end

  def should_show_edit_button?
    token_type == nil || token_type == :readwrite
  end

  def tag_suggestions_for partial_or_full_tag_name
    all_tags = user_page_tags.search(partial_or_full_tag_name)
    all_tags - ObjectTags.new(page).sorted_tag_names()
  end

  def fully_rendered_text
    text = text_before_markdown_parsing
    rendered_markdown text
  end

  def text_before_markdown_parsing
    text = PageLinks.new(user)
      .internal_links_to_user_clickable_links(page.text)
    text = text_with_stylized_partial_definitions(text, name)
    text = PagePartialIncluder.new.
      replace_links_to_partials_with_actual_content(text)
    text
  end

  def text_with_stylized_partial_definitions text, page_name
    PagePartials.new(text).replace_definitions_with do |name|
      %Q{<span style="background-color:#ddd;"> #{page_name}##{name}} +
       "</span>"
    end
  end

  def rendered_markdown(text)
    markdown = ::Redcarpet::Markdown.new(Redcarpet::Render::HTML,
      :autolink => true, :space_after_headers => true, :tables => true)
    markdown.render text
  end

  private def page_tags
    ObjectTags.new(page)
  end

  private def user_page_tags
    UserPageTags.new(user, page)
  end

end
