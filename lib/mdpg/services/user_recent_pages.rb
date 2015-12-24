class UserRecentPages < Struct.new(:user)
  MAX_HISTORY = 250

  def add_to_recent_created_pages_list(page)
    user.recent_created_page_ids =
      get_list_with_page_added(page, user.recent_created_page_ids)
    user.save
  end

  def add_to_recent_edited_pages_list(page)
    user.recent_edited_page_ids =
      get_list_with_page_added(page, user.recent_edited_page_ids)
    user.save
  end

  def add_to_recent_viewed_pages_list(page)
    user.recent_viewed_page_ids =
      get_list_with_page_added(page, user.recent_viewed_page_ids)
    user.save
  end

  def remove_from_all_recent_pages_lists(page)
    user.recent_created_page_ids =
      remove_from_recent_pages_lists(page, user.recent_created_page_ids)
    user.recent_viewed_page_ids =
      remove_from_recent_pages_lists(page, user.recent_viewed_page_ids)
    user.recent_edited_page_ids =
      remove_from_recent_pages_lists(page, user.recent_edited_page_ids)
  end

  private def get_list_with_page_added(page, pre_existing_ids)
    ids = remove_from_recent_pages_lists(page, pre_existing_ids)
    ids.unshift page.id
    ids[0..MAX_HISTORY-1]
  end

  private def remove_from_recent_pages_lists(page, pre_existing_ids)
    ids = pre_existing_ids || []
    ids.reject { |x| x == page.id }
  end
end
