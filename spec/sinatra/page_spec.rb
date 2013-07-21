require File.expand_path '../spec_helper.rb', __FILE__

describe "page" do

  before do
    $data_store = get_memory_datastore()

    @user = Wnp::Models::User.create name:"Jordan",
      email:"jordan@example.com", password:"cool"
    user_pages = Wnp::Services::UserPages.new @user
    Wnp::Services::UserPages.new(@user).create_page name:"a-good-page",
      text:"I wish I had something *interesting* to say!"
  end

  def get_page name
    get "/p/#{name}", {},
      {"rack.session" => {:access_token => @user.access_token}}
  end

  it "should get a page that is owned by the user" do
    get_page "a-good-page"
    expected = "<p>I wish I had something <em>interesting</em> to say!</p>\n"
    assert_equal expected, last_response.body 
  end

  it "should not get a page if the user does not have a page by that name" do
    get_page "not-one-of-the-users-pages"
    assert_equal "Could not find that page", last_response.body 
  end

  it "should redirect to login form if the access_token is invalid" do
    get '/p/other', {}, {"rack.session" => {:access_token => "some nonsense"}}
    follow_redirect!
    assert last_response.body.include? "Please login"
  end

end
