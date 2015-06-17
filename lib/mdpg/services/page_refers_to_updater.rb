class PageRefersToUpdater

  def initialize page, user
    page_links = PageLinks.new(user)
    page_partial_includer = PagePartialIncluder.new

    @user = user
    @page = page

    page_links_ids = page_links.get_page_ids(@page.text)

    partial_pages_ids = page_partial_includer.get_page_ids(
      UserPages.new(user), @page.text
    )

    @old_ids = page.refers_to_page_ids || []
    @new_ids = [page_links_ids + partial_pages_ids].flatten.uniq
  end

  def update
    remove_outdated_refers_to
    add_new_refers_to
    save_refers_to_page_ids_to_page
  end

  private def remove_outdated_refers_to
    removed_pages.each do |target_page|
      PageReferrersUpdater.new.remove_page_id_from_referrers(
        @page.id, target_page
      )
    end
  end

  private def add_new_refers_to
    added_pages.each do |target_page|
      PageReferrersUpdater.new.add_page_id_to_referrers(
        @page.id, target_page
      )
    end
  end

  private def save_refers_to_page_ids_to_page
    @page.refers_to_page_ids = @new_ids
    @page.save
  end

  private def added_pages
    pages_for(@new_ids - @old_ids)
  end

  private def removed_pages
    pages_for(@old_ids - @new_ids)
  end

  private def pages_for page_ids
    page_ids.map{|x| Page.find(x)}
  end

end
