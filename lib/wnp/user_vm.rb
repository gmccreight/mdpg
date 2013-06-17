module Wnp

  class UserVm < Struct.new(:env, :user)

    def page_ids_and_names_sorted_by_name
      page_ids_and_names.sort{|a,b| a[1] <=> b[1]}
    end

    private

      def page_ids_and_names
        user.get_page_ids().
          map{|x| page = Page.new(env, x); page.load; [page.id, page.name]}
      end

  end

end
