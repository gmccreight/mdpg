require "search_query_parser"

class Search

  def initialize user
    @user_pages = UserPages.new(user)
    @user_page_tags = UserPageTags.new(user, nil)
    @search_query = SearchQueryParser.new()
  end

  def search query
    @search_query.query = query
    @search_string = @search_query.search_string()

    names = search_names()
    texts = search_texts()
    tags = search_tags()

    {names: names, texts:texts, tags:tags}
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
    return pages if @search_query.tags.size == 0

    pages = pages.select{|page|
      (ObjectTags.new(page).sorted_tag_names() & @search_query.tags).size > 0
    }
  end

end
