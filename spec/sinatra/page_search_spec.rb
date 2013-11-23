require File.expand_path '../sinatra_helper.rb', __FILE__

describe "page_search" do

  before do
    $data_store = get_memory_datastore()

    @user = User.create name:"Jordan",
      email:"jordan@example.com", password:"cool"
    UserPages.new(@user).create_page name:"good-page-name",
      text:"I wish I had something *interesting* to say!"
    UserPages.new(@user).create_page name:"cool-interesting-things",
      text:"Fast cars"
  end

  def search_pages query
    post "/page/search", {:query => query}, authenticated_session(@user)
    last_response.body
  end

  it "should integrate the search ok" do
    text = search_pages "good"

    assert text.include? "1 pages with matching name"
    assert text.include? "good-page-name"
    assert text.include? "0 pages with matching text"
  end

end
