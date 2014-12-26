class PageLinks < Struct.new(:user)

  def internal_links_to_user_clickable_links text
    altered_text text, mode: :user_clickable_link
  end

  def internal_links_to_page_name_links_for_editing text
    altered_text text, mode: :page_name_link_for_editing
  end

  def page_name_links_to_ids text
    return text if ! text
    text.gsub(/\[\[(#{Token::TOKEN_REGEX_STR})\]\]/) do

      page_name = $1
      user_pages = UserPages.new(user)
      if page = user_pages.find_page_with_name(page_name)
        "[[mdpgpage:#{page.id}]]"
      else
        "[[#{$1}]]"
      end
    end
  end

  private def altered_text text, mode:
    return text if ! text
    text.gsub(/\[\[mdpgpage:(\d+)\]\]/) do
      id = $1.to_i
      name = Page.find(id).name
      if mode == :user_clickable_link
        "[#{name}](/p/#{name})"
      elsif mode == :page_name_link_for_editing
        "[[#{name}]]"
      end
    end
  end

end
