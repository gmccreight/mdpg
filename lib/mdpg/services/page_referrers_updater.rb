class PageReferrersUpdater

  def add_page_id_to_referrers(page_id, target_page)
    if target_page.has_any_referring_pages?
      if ! target_page.referring_page_ids.include?(page_id)
        ids = target_page.referring_page_ids
        ids << page_id
        ids = ids.sort
        target_page.referring_page_ids = ids
        target_page.save
      end
    else
      target_page.referring_page_ids = [page_id]
      target_page.save
    end
  end

  def remove_page_id_from_referrers(page_id, target_page)
    if target_page.has_any_referring_pages?
      if target_page.referring_page_ids.include?(page_id)
        target_page.referring_page_ids = target_page.referring_page_ids.
          reject{|x| x == page_id}
        target_page.save
      end
    end
  end

end
