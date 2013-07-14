module Wnp::Services

  class UserPages < Struct.new(:user)

    def add_page opts
      page = Wnp::Models::Page.create opts
      if page
        user.add_page page.id
      end
      page
    end

    def pages_with_names_containing_text query
      pages.select{|page| page.name_contains(query)}
    end

    def pages_with_text_containing_text query
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
        user.page_ids().map{|x| page = Wnp::Models::Page.find(x); page}
      end

  end

end
