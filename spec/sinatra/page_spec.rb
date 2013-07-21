require File.expand_path '../spec_helper.rb', __FILE__

describe "page" do

  before do
    $data_store = get_memory_datastore()

    @user = Wnp::Models::User.create name:"Jordan", email:"jordan@example.com", password:"cool"
    user_pages = Wnp::Services::UserPages.new @user
    Wnp::Services::UserPages.new(@user).create_page name:"a-good-page", text:"I wish I had something *interesting* to say!"
  end

  it "should get a page that is owned by the user" do
    get '/p/a-good-page', {}, {"rack.session" => {:access_token => @user.access_token}}
    assert_equal "<p>I wish I had something <em>interesting</em> to say!</p>\n", last_response.body 
  end

  it "should not get a page if the user does not have a page by that name" do
    get '/p/not-a-page', {}, {"rack.session" => {:access_token => @user.access_token}}
    assert_equal "Could not find that page", last_response.body 
  end

  it "should give an error if the access_token does not map to a user" do
    get '/p/other', {}, {"rack.session" => {:access_token => "some nonsense"}}
    assert_equal "Could not find that user", last_response.body 
  end

end
