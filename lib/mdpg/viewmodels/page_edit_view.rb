class PageEditView < Struct.new(:user, :page)

  def get_text
    text = PageLinks.new(user)
      .internal_links_to_page_name_links_for_editing(page.text)
    text = PagePartialIncluder.new.internal_links_to_user_facing_links(text)
    text
  end

end
