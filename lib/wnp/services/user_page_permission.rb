require 'wnp/user'
require 'wnp/page'

module Wnp::Services

  class UserPagePermission < Struct.new(:user, :page)

    def can_read?
      is_owned_by?
    end

    def can_write?
      is_owned_by?
    end

    private

      def is_owned_by?
        user.get_page_ids.include? page.id
      end

  end

end
