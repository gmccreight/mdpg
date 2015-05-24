class PageLinks < Struct.new(:user)

  def initialize user
    @user_pages = UserPages.new(user)
    super(user)
  end

  def get_page_ids text
    page_names = []
    alter_text(text) {|name| page_names << name}
    page_names.map{|x| user_page_for_name(x)}.compact.map{|x| x.id}
  end

  def internal_links_to_user_clickable_links text
    alter_text(text) {|name| "[#{name}](/p/#{name})"}
  end

  def internal_links_to_page_name_links_for_editing text
    alter_text(text) {|name| "[[#{name}]]"}
  end

  def page_name_links_to_ids text
    return text if ! text
    text.gsub(/\[\[(#{Token::TOKEN_REGEX_STR})\]\]/) do
      page_name = $1
      if page = user_page_for_name(page_name)
        "[[mdpgpage:#{page.id}]]"
      else
        "[[#{$1}]]"
      end
    end
  end

  private def user_page_for_name page_name
    @user_pages.find_page_with_name(page_name)
  end

  private def alter_text text
    return text if ! text
    text.gsub(/\[\[mdpgpage:(\d+)\]\]/) do
      id = $1.to_i
      name = Page.find(id).name
      yield name
    end
  end

end
