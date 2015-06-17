class PageEditView < Struct.new(:user, :page)

  def get_text
    PageLinks.new(user)
      .internal_links_to_page_name_links_for_editing(page.text)
  end

end
