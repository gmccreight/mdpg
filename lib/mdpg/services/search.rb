class Search

  def initialize user
    @user_pages = UserPages.new(user)
    @user_page_tags = UserPageTags.new(user, nil)
    @search_query = SearchQueryParser.new()
  end

  def search query
    @search_query.query = query
    search_string = @search_query.search_string()
    names = @user_pages.pages_with_names_containing_text(search_string)
    texts = @user_pages.pages_with_text_containing_text(search_string)
    tags = @user_page_tags.search(search_string)
    {names: names, texts:texts, tags:tags}
  end

end
