# frozen_string_literal: true

class UserPagePermission < Struct.new(:user, :page)
  def can_read?
    owned_by?
  end

  def can_write?
    owned_by?
  end

  private def owned_by?
    return false unless user.page_ids
    user.page_ids.include? page.id
  end
end
