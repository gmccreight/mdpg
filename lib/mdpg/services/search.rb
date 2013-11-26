require "search_query_parser"

class Search

  def initialize user
    @user_pages = UserPages.new(user)
    @user_page_tags = UserPageTags.new(user, nil)
    @search_parser = SearchQueryParser.new()
  end

  def search query
    @search_parser.query = query
    @search_string = @search_parser.search_string()

    names = search_names()
    texts = search_texts()
    tags = search_tags()

    redirect_to_perfect_match = redirect_to_perfect_match(names)

    {names: names, texts:texts, tags:tags, redirect:redirect_to_perfect_match}
  end

  def redirect_to_perfect_match(names)
    return nil if @search_parser.force_full_search()

    if names.size > 0 && names.map(&:name).include?(@search_string)
      return @search_string
    end

    nil
  end

  def search_names
    pages_containing_one_of_the_tags(
      @user_pages.pages_with_names_containing_text(@search_string))
  end

  def search_texts
    pages_containing_one_of_the_tags(
      @user_pages.pages_with_text_containing_text(@search_string))
  end

  def search_tags
    @user_page_tags.search(@search_string)
  end

  def pages_containing_one_of_the_tags pages
    return pages if @search_parser.tags.size == 0

    pages = pages.select{|page|
      (ObjectTags.new(page).sorted_tag_names() & @search_parser.tags).size > 0
    }
  end

end
