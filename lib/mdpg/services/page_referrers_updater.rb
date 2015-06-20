class PageReferrersUpdater

  def add_page_id_to_referrers(page_id, target_page)

    if !target_page.has_any_referring_pages?
      target_page.referring_page_ids = [page_id]
      target_page.save
      return
    end

    if !target_page.referring_page_ids.include?(page_id)
      target_page.referring_page_ids += [page_id]
      target_page.referring_page_ids.sort!
      target_page.save
    end
  end

  def remove_page_id_from_referrers(page_id, target_page)
    return if !target_page.has_any_referring_pages?
    return if !target_page.referring_page_ids.include?(page_id)

    target_page.referring_page_ids -= [page_id]
    target_page.save
  end

end
