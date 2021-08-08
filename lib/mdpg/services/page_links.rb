# frozen_string_literal: true

class PageLinks < Struct.new(:user)
  def initialize(user)
    @user_pages = UserPages.new(user)
    super(user)
  end

  def get_page_ids(text)
    page_names = []
    alter_text(text) { |page_name| page_names << page_name }
    page_names.map { |x| user_page_for_name(x) }.compact.map(&:id)
  end

  def internal_to_user_clickable_links(text)
    alter_text_to_make_link(text) do |page_name, link_name|
      "[#{link_name}](/p/#{page_name})"
    end
  end

  def internal_links_to_links_for_editing(text)
    alter_text(text) { |page_name| "[[#{page_name}]]" }
  end

  def page_name_links_to_ids(text)
    return text unless text
    text.gsub(/\[\[(#{Token::TOKEN_REGEX_STR})\]\]/) do
      page_name = Regexp.last_match(1)
      page = user_page_for_name(page_name)
      if page
        "[[mdpgpage:#{page.id}]]"
      elsif page_name =~ /^new-/
        new_name = page_name.sub(/^new-/, '')
        page = @user_pages.create_page(name: new_name)
        "[[mdpgpage:#{page.id}]]"
      else
        "[[#{page_name}]]"
      end
    end
  end

  private def user_page_for_name(page_name)
    @user_pages.find_page_with_name(page_name)
  end

  private def alter_text(text)
    return text unless text
    text.gsub(/\[\[mdpgpage:(\d+)\]\]/) do
      id = Regexp.last_match(1).to_i
      page_name = Page.find(id).name
      yield page_name
    end
  end

  private def alter_text_to_make_link(text)
    # [[mdpgpage:11]]
    # or
    # [[mdpgpage:11]]((some overriding special name))
    return text unless text
    text.gsub(/(\[\[mdpgpage:(\d+)\]\])(\(\(([^()]+)\)\))?/) do
      id = Regexp.last_match(2).to_i
      page_name = Page.find(id).name
      optional_link_name = Regexp.last_match(4)
      link_name = optional_link_name || page_name
      yield page_name, link_name
    end
  end

end
