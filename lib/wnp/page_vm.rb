module Wnp

  class PageVm < Struct.new(:env, :page)

    def add_tag(tag)
      if page_tags().add_tag(tag)
        user_tags().add_tag(tag, page.id)
      end
    end

    def remove_tag(tag)
      if page_tags().remove_tag(tag)
        user_tags().remove_tag(tag, page.id)
      end
    end

    private

      def page_tags
        Wnp::PageTags.new(env.data, page.id)
      end

      def user_tags
        Wnp::UserTags.new(env.data, page.id)
      end

  end

end
