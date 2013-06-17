require 'wnp/user'
require 'wnp/page'

module Wnp

  class PagePermission < Struct.new(:user, :page)

    def can_view?
      is_owned_by?
    end

    def can_edit?
      is_owned_by?
    end

    private

      def is_owned_by?
        user.get_page_ids.include? page.id
      end

  end

end
