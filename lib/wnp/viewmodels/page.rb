require 'redcarpet'

class PageView < Struct.new(:user, :page)

  def name
    page.name
  end

  def add_tag tag
    if page_tags().add_tag(tag)
      user_page_tags().add_tag tag
    end
  end

  def remove_tag tag
    if page_tags().remove_tag(tag)
      user_page_tags().remove_tag tag
    end
  end

  def rendered_markdown
    markdown = ::Redcarpet::Markdown.new(Redcarpet::Render::HTML,
      :autolink => true, :space_after_headers => true)
    markdown.render page.text
  end

  private

    def page_tags
      Wnp::Services::ObjectTags.new(page)
    end

    def user_page_tags
      Wnp::Services::UserPageTags.new(user, page)
    end

end
