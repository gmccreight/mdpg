require 'securerandom'

class PageAlreadyExistsException < Exception
end

class PageCannotBeDeletedBecauseItHasReferringPages < Exception
end

class UserPages < Struct.new(:user)

  def initialize(user)
    @pages_cache = nil
    super(user)
  end

  def create_page(opts)
    if opts[:name]
      if find_page_with_name(opts[:name])
        fail PageAlreadyExistsException
      end
    end

    if opts[:name].empty?
      opts[:name] = SecureRandom.hex
    end

    page = Page.create opts
    if page
      update_page_text_to(page, page.text)
      user.add_page page
      page_ids_or_names_have_changed
    end
    page
  end

  def update_page_text_to(page, new_text)
    new_text = add_missing_identifiers_to_labeled_sections(new_text)
    new_text = page_text_with_links_escaped(new_text)
    new_text = page_text_with_labeled_section_includes_canonicalized(new_text)

    page.text = new_text
    page.save

    PageRefersToUpdater.new(page, user).update
  end

  private def page_text_with_labeled_section_includes_canonicalized(new_text)
    LabeledSectionTranscluder.new
      .user_facing_links_to_internal_links(new_text, self)
  end

  private def add_missing_identifiers_to_labeled_sections(text)
    parser = LabeledSectionParser.new(text)
    parser.add_any_missing_identifiers
  end

  def delete_page(name)
    page = find_page_with_name(name)
    if page
      if page.referring_page_ids && page.referring_page_ids.size > 0
        fail PageCannotBeDeletedBecauseItHasReferringPages
      end
      if page.refers_to_page_ids && page.refers_to_page_ids.size > 0
        page.refers_to_page_ids.each do |page_id_referred_to|
          PageReferrersUpdater.new.remove_page_id_from_referrers(
            page.id, Page.find(page_id_referred_to)
          )
        end
      end
      user.remove_page(page)
      user_page_tags = UserPageTags.new(user, page)
      user_page_tags.remove_all
      page.virtual_delete
      page_ids_or_names_have_changed
    end
  end

  def duplicate_page(name)
    original_page = find_page_with_name(name)
    if original_page
      duplicator = UserPageDuplicator.new(self, user, original_page)
      new_page = duplicator.duplicate
      page_ids_or_names_have_changed
      return new_page
    end
    nil
  end

  def rename_page(page, new_name)
    if find_page_with_name new_name
      fail PageAlreadyExistsException
    else
      page.name = new_name
      worked = page.save
      if worked
        page_ids_or_names_have_changed
      end
      return worked
    end
  end

  def page_was_updated(page)
    UserRecentPages.new(user).add_to_recent_edited_pages_list(page)
  end

  def find_page_with_name(name)
    matching_pages = pages.select { |page| page.name == name }
    return nil if !matching_pages
    matching_pages.first
  end

  def pages_with_names_containing_text(query)
    pages.select { |page| page.name_contains?(query) }
  end

  def pages_with_text_containing_text(query)
    pages.select { |page| page.text_contains?(query) }
  end

  def page_ids_and_names_sorted_by_name
    page_ids_and_names.sort { |a, b| a[1] <=> b[1] }
  end

  def pages
    return @pages_cache if @pages_cache
    if !user.page_ids
      @pages_cache = []
    else
      @pages_cache = user.page_ids.map { |x| page = Page.find(x); page }
    end
    @pages_cache
  end

  private def page_text_with_links_escaped(new_text)
    page_links = PageLinks.new(user)
    page_links.page_name_links_to_ids(new_text)
  end

  private def page_ids_and_names
    pages.map { |x| [x.id, x.name] }
  end

  private def page_ids_or_names_have_changed
    clear_caches
  end

  private def clear_caches
    @pages_cache = nil
  end

end
