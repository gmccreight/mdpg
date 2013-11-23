require_relative "../../spec_helper"

describe Search do

  before do
    @user = create_user
    UserPages.new(@user).create_page name:"good-page-name",
      text:"I wish I had something *interesting* to say!"
    UserPages.new(@user).create_page name:"cool-interesting-things",
      text:"Fast cars"
    @searcher = Search.new(@user)
  end


  it "should get a page with a matching name" do
    results = @searcher.search "good"
    assert_equal results[:names].size, 1
    assert_equal results[:texts].size, 0
  end

  it "should get a page with matching text" do
    results = @searcher.search "car"
    assert_equal results[:names].size, 0
    assert_equal results[:texts].size, 1
  end

  it "should get a page with matching text, ignoring case" do
    results = @searcher.search "Car"
    assert_equal results[:names].size, 0
    assert_equal results[:texts].size, 1
  end

end
