module Wnp

  class UserPages < Struct.new(:env, :user)

    def pages_containing_text(query)
      pages.select{|page| page.text_contains(query)}
    end

    def page_ids_and_names_sorted_by_name
      page_ids_and_names.sort{|a,b| a[1] <=> b[1]}
    end

    private

      def page_ids_and_names
        pages.map{|x| [x.id, x.name]}
      end

      def pages
        user.get_page_ids().map{|x| page = Page.new(env, x); page.load; page}
      end

  end

end
