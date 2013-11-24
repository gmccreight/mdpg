require_relative "../../spec_helper"

describe Search do

  before do
    @user = create_user
    page = UserPages.new(@user).create_page name:"good-page-name",
      text:"I wish I had something *interesting* to say!"
    UserPageTags.new(@user, page).add_tag "wishing"
    UserPageTags.new(@user, page).add_tag "blog-ideas"

    page = UserPages.new(@user).create_page name:"cool-interesting-things",
      text:"Fast cars"
    UserPageTags.new(@user, page).add_tag "vehicular"
    UserPageTags.new(@user, page).add_tag "blog-ideas"
    @searcher = Search.new(@user)
  end

  def search_for_should_give_names_texts_tags query, names, texts, tags
    results = @searcher.search query
    assert_equal names, results[:names].size
    assert_equal texts, results[:texts].size
    assert_equal tags, results[:tags].size
  end

  it "should find name" do
    search_for_should_give_names_texts_tags "good", 1, 0, 0
  end

  it "should find text" do
    search_for_should_give_names_texts_tags "car", 0, 1, 0
  end

  it "should ignore case of query" do
    search_for_should_give_names_texts_tags "Car", 0, 1, 0
  end

  describe "tags" do

    it "should find single exact match" do
      search_for_should_give_names_texts_tags "vehicular", 0, 0, 1
    end

    it "should find single similar match" do
      search_for_should_give_names_texts_tags "vehicles", 0, 0, 1
    end

    it "should return only one tag even if multiple found" do
      search_for_should_give_names_texts_tags "blog-ideas", 0, 0, 1
    end

  end

end
