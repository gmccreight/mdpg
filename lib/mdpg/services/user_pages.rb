class UserPages < Struct.new(:user)

  def create_page opts
    page = Page.create opts
    if page
      user.add_page page
    end
    page
  end

  def delete_page name
    if page = find_page_with_name(name)
      user.remove_page(page)
      page.virtual_delete()
    end
  end

  def find_page_with_name name
    matching_pages = pages.select{|page| page.name == name}
    return nil if ! matching_pages
    matching_pages.first
  end

  def pages_with_names_containing_text query
    pages.select{|page| page.name_contains(query)}
  end

  def pages_with_text_containing_text query
    pages.select{|page| page.text_contains(query)}
  end

  def page_ids_and_names_sorted_by_name
    page_ids_and_names.sort{|a,b| a[1] <=> b[1]}
  end

  private

    def page_ids_and_names
      pages.map{|x| [x.id, x.name]}
    end

    def pages
      return [] if ! user.page_ids()
      user.page_ids().map{|x| page = Page.find(x); page}
    end

end
