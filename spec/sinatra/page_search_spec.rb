require File.expand_path '../sinatra_helper.rb', __FILE__

describe "page_search" do

  before do
    $data_store = get_memory_datastore()

    @user = User.create name:"Jordan",
      email:"jordan@example.com", password:"cool"
    user_pages = UserPages.new @user
    UserPages.new(@user).create_page name:"good-page-name",
      text:"I wish I had something *interesting* to say!"
    UserPages.new(@user).create_page name:"cool-interesting-things",
      text:"Fast cars"
  end

  def search_pages query
    post "/page/search", {:query => query}, authenticated_session(@user)
    last_response.body
  end

  it "should get a page with a matching name" do
    text = search_pages "good"

    assert text.include? "1 pages with matching name"
    assert text.include? "good-page-name"
    assert text.include? "0 pages with matching text"
  end

  it "should get a page with matching text" do
    text = search_pages "car"

    assert text.include? "0 pages with matching name"
    assert text.include? "1 pages with matching text"
    assert text.include? "cool-interesting-things"
  end

end
