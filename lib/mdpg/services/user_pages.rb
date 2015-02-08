require 'securerandom'

class PageAlreadyExistsException < Exception
end

class PageCannotBeDeletedBecauseItHasReferringPages < Exception
end

class UserPages < Struct.new(:user)

  def create_page opts
    if opts[:name]
      if find_page_with_name(opts[:name])
        raise PageAlreadyExistsException
      end
    end

    if opts[:name].empty?
      opts[:name] = SecureRandom.hex
    end

    page = Page.create opts
    if page
      update_page_text_to(page, page.text)
      user.add_page page
    end
    page
  end

  def update_page_text_to page, text
    page_links = PageLinks.new(user)
    old_ids = page.refers_to_page_ids || []
    page.text = page_links.page_name_links_to_ids(text)
    page.save
    new_ids = page_links.get_page_ids(page.text)

    page_ids_removed(old_ids, new_ids).each do |page_id|
      target_page = Page.find(page_id)
      PageReferrersUpdater.new.remove_page_id_from_referrers(
        page.id, target_page
      )
    end

    new_ids.each do |page_id|
      if ! old_ids.include?(page_id)
        target_page = Page.find(page_id)
        PageReferrersUpdater.new.add_page_id_to_referrers(
          page.id, target_page
        )
      end
    end

    page.refers_to_page_ids = new_ids
    page.save
  end

  private def page_ids_removed old_ids, new_ids
    results = []
    old_ids.each do |old_id|
      if ! new_ids.include?(old_id)
        results << old_id
      end
    end
    results
  end

  def delete_page name
    if page = find_page_with_name(name)
      if page.referring_page_ids && page.referring_page_ids.size > 0
        raise PageCannotBeDeletedBecauseItHasReferringPages
      end
      user.remove_page(page)
      user_page_tags = UserPageTags.new(user, page)
      user_page_tags.remove_all()
      page.virtual_delete()
    end
  end

  def duplicate_page name
    if original_page = find_page_with_name(name)
      increment = 2
      new_name = "#{name}-#{increment}"
      while find_page_with_name(new_name)
        increment += 1
        new_name = "#{name}-#{increment}"
      end
      new_page = create_page({:name => new_name})
      new_page.text = original_page.text

      user_page_tags = UserPageTags.new(user, original_page)
      user_page_tags.duplicate_tags_to_other_page(new_page)

      new_page.save()
      return new_page
    end
    nil
  end

  def rename_page page, new_name
    if find_page_with_name new_name
      raise PageAlreadyExistsException
    else
      page.name = new_name
      return page.save()
    end
  end

  def page_was_updated page
    UserRecentPages.new(user).add_to_recent_edited_pages_list(page)
  end

  def find_page_with_name name
    matching_pages = pages.select{|page| page.name == name}
    return nil if ! matching_pages
    matching_pages.first
  end

  def pages_with_names_containing_text query
    pages.select{|page| page.name_contains?(query)}
  end

  def pages_with_text_containing_text query
    pages.select{|page| page.text_contains?(query)}
  end

  def page_ids_and_names_sorted_by_name
    page_ids_and_names.sort{|a,b| a[1] <=> b[1]}
  end

  def pages
    return [] if ! user.page_ids()
    user.page_ids().map{|x| page = Page.find(x); page}
  end

  private def page_ids_and_names
    pages.map{|x| [x.id, x.name]}
  end

end
