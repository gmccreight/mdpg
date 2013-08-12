class UserPagePermission < Struct.new(:user, :page)

  def can_read?
    is_owned_by?
  end

  def can_write?
    is_owned_by?
  end

  private

    def is_owned_by?
      return false if ! user.page_ids
      user.page_ids.include? page.id
    end

end
