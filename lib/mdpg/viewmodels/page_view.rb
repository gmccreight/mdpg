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
    if partial_or_full_tag_name == "*"
      all_tags = user_page_tags.get_tag_names()
    else
      all_tags = user_page_tags.search(partial_or_full_tag_name)
    end
    all_tags - ObjectTags.new(page).sorted_tag_names()
  end

  def fully_rendered_text
    text = PageLinks.new(user)
      .internal_links_to_user_clickable_links(page.text)
    rendered_markdown text
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
