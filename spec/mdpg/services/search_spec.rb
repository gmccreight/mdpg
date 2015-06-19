require_relative "../../spec_helper"

describe Search do

  before do
    $data_store = get_memory_datastore()
    @user = create_user
    @page_1 = UserPages.new(@user).create_page name:"good-page-name",
      text:"I wish I had something *interesting* to say!"

    @page_2 = UserPages.new(@user).create_page name:"cool", text:"Fast cars"
    @searcher = Search.new(@user)
  end

  def search_gets query, names, texts, tags
    results = @searcher.search query
    assert_equal names, results[:names].size
    assert_equal texts, results[:texts].size
    assert_equal tags, results[:tags].size
  end

  it "should find name" do
    search_gets "good", 1, 0, 0
  end

  it "should find text" do
    search_gets "car", 0, 1, 0
  end

  describe "case insensitivity" do

    it "should ignore case and find lower case version of query" do
      search_gets "Car", 0, 1, 0
    end

    it "should ignore case and find upper case page text" do
      search_gets "fast", 0, 1, 0
    end

  end

  describe "redirecting to single page that matches by name" do

    def search_redirects query, pagename_or_nil
      results = @searcher.search query
      assert_equal pagename_or_nil, results[:redirect]
    end

    it "should redirect if only one page matches by name exactly" do
      search_redirects "good-page-name", "good-page-name"
    end

    it "should not redirect if off by even one character" do
      search_redirects "good-page-fame", nil
    end

    it "should not redirect if exact match but has ! at end" do
      search_redirects "good-page-name!", nil
    end

    it "should give normal results with the forcing-full-search syntax" do
      search_gets "good-page-name", 1, 0, 0
    end

    it "should not redirect to the page after it is deleted" do
      UserPages.new(@user).delete_page "good-page-name"
      search_redirects "good-page-name", nil
    end

  end

  describe "tags" do

    before do
      UserPageTags.new(@user, @page_1).add_tag "wishing"
      UserPageTags.new(@user, @page_1).add_tag "blog-ideas"
      UserPageTags.new(@user, @page_2).add_tag "vehicular"
      UserPageTags.new(@user, @page_2).add_tag "blog-ideas"
    end

    describe "searching for tag name" do

      it "should find single exact match" do
        search_gets "vehicular", 0, 0, 1
      end

      it "should find single similar match" do
        search_gets "vehicles", 0, 0, 1
      end

      it "should return only one tag even if multiple found" do
        search_gets "blog-ideas", 0, 0, 1
      end

    end

    describe "search with tags limiter" do

      describe "names" do

        it "should find name if name matches and tag limiter matches" do
          search_gets "good tags:wishing", 1, 0, 0
        end

        it "should find name if name matches and tag limiter matches" do
          search_gets "good tags:blog-ideas", 1, 0, 0
        end

        it "should not find name if name matches but tags do not" do
          search_gets "good tags:nope", 0, 0, 0
        end

      end

      describe "texts" do

        it "should find text if text matches and tag limiter matches" do
          search_gets "cars tags:vehicular", 0, 1, 0
        end

        it "should find text if text matches and tag limiter matches" do
          search_gets "cars tags:cat,vehicular,dog", 0, 1, 0
        end

        it "should not find text if text matches but tags do not" do
          search_gets "cars tags:nope", 0, 0, 0
        end

      end

    end

  end

end
