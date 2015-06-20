class UserPage < Struct.new(:user, :page)

  def text_for_editing
    page_links.internal_links_to_page_name_links_for_editing(page.text)
  end

  def text_for_display
    page_links.internal_links_to_page_name_links_for_editing(page.text)
  end

  def page_links
    PageLinks.new(user)
  end

end
