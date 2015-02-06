class UserRecentPages < Struct.new(:user)

  def add_to_recent_edited_pages_list page
    user.recent_edited_page_ids =
      _get_list_with_page_added(page, user.recent_edited_page_ids)
    user.save
  end

  def add_to_recent_viewed_pages_list page
    user.recent_viewed_page_ids =
      _get_list_with_page_added(page, user.recent_viewed_page_ids)
    user.save
  end

  def remove_from_all_recent_pages_lists page
    user.recent_viewed_page_ids =
      _remove_from_recent_pages_lists(page, user.recent_viewed_page_ids)
    user.recent_edited_page_ids =
      _remove_from_recent_pages_lists(page, user.recent_edited_page_ids)
  end

  private def _get_list_with_page_added page, pre_existing_ids
    ids = _remove_from_recent_pages_lists(page, pre_existing_ids)
    ids.unshift page.id
    ids
  end

  private def _remove_from_recent_pages_lists page, pre_existing_ids
    ids = pre_existing_ids || []
    ids.reject{|x| x == page.id}
  end

end
