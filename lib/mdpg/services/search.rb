require "search_query_parser"

class Search

  private def initialize user
    @user_pages = UserPages.new(user)
    @user_page_tags = UserPageTags.new(user, nil)
    @search_parser = SearchQueryParser.new()
  end

  def search query
    @search_parser.query = query

    names = search_names()

    {
      :names => names,
      :texts => search_texts(),
      :tags => search_tags(),
      :redirect => redirect_to_perfect_match(names),
      :redirect_to_edit_mode => @search_parser.should_open_in_edit_mode?()
    }
  end

  private def search_string
    @search_string ||= @search_parser.search_strings()[0]
  end

  private def redirect_to_perfect_match(names)
    return nil if @search_parser.should_force_full_search?()

    if names.size > 0 && names.map(&:name).include?(search_string)
      return search_string
    end

    nil
  end

  private def search_names
    pages_containing_one_of_the_tags(
      @user_pages.pages_with_names_containing_text(search_string))
  end

  private def search_texts
    pages_containing_one_of_the_tags(
      @user_pages.pages_with_text_containing_text(search_string))
  end

  private def search_tags
    @user_page_tags.search(search_string)
  end

  private def pages_containing_one_of_the_tags pages
    return pages if @search_parser.tags.size == 0

    pages.select{|page|
      (ObjectTags.new(page).sorted_tag_names() & @search_parser.tags).size > 0
    }
  end

end
