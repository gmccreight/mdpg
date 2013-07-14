require 'redcarpet'

module Wnp::Viewmodels

  class Page < Struct.new(:env, :page)

    def add_tag tag
      if page_tags().add_tag(tag)
        user_page_tags().add_tag(tag, page.id)
      end
    end

    def remove_tag tag
      if page_tags().remove_tag(tag)
        user_page_tags().remove_tag(tag, page.id)
      end
    end

    def rendered_html
      markdown = ::Redcarpet::Markdown.new(Redcarpet::Render::HTML, :autolink => true, :space_after_headers => true)
      markdown.render page.text
    end

    private

      def page_tags
        Wnp::Services::ObjectTags.new(page)
      end

      def user_page_tags
        Wnp::Services::UserPageTags.new(env.user, page)
      end

  end

end
