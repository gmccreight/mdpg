class Search

  def initialize user
    @user_pages = UserPages.new(user)
    @user_page_tags = UserPageTags.new(user, nil)
  end

  def search query
    names = @user_pages.pages_with_names_containing_text(query)
    texts = @user_pages.pages_with_text_containing_text(query)
    tags = @user_page_tags.search(query)
    {names: names, texts:texts, tags:tags}
  end

end
