class PageRefersToUpdater

  def initialize page, user
    page_links = PageLinks.new(user)

    @user = user
    @page = page
    @old_ids = page.refers_to_page_ids || []
    @new_ids = page_links.get_page_ids(@page.text)
  end

  def update
    remove_outdated_refers_to
    add_new_refers_to
    save_refers_to_page_ids_to_page
  end

  private def remove_outdated_refers_to
    for_page_id(removed_page_ids) do |page_id, target_page|
      PageReferrersUpdater.new.remove_page_id_from_referrers(
        page_id, target_page
      )
    end
  end

  private def add_new_refers_to
    for_page_id(added_page_ids) do |page_id, target_page|
      PageReferrersUpdater.new.add_page_id_to_referrers(
        page_id, target_page
      )
    end
  end

  private def for_page_id page_ids
    page_ids.each do |target_page_id|
      target_page = Page.find(target_page_id)
      yield @page.id, target_page
    end
  end

  private def save_refers_to_page_ids_to_page
    @page.refers_to_page_ids = @new_ids
    @page.save
  end

  private def added_page_ids
    @new_ids - @old_ids
  end

  private def removed_page_ids
    @old_ids - @new_ids
  end

end
