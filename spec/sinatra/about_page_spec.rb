require File.expand_path '../spec_helper.rb', __FILE__

describe "the wnp app" do

  before do
    $data_store = get_memory_datastore()
  end

  it "should successfully return the about page" do
    get '/about' 
    assert_equal 'about this', last_response.body 
  end

  it "should get a page that is owned by the user" do
    user = Wnp::Models::User.create name:"Jordan", email:"good@email.com", password:"cool"
    user_pages = Wnp::Services::UserPages.new user
    page = Wnp::Services::UserPages.new(user).create_page name:"foo-cool"
    get '/p/foo-cool', {}, {"rack.session" => {:access_token => user.access_token}}
    assert_equal "You're looking at page foo-cool", last_response.body 
  end

  it "should not get a page if the user does not have a page by that name" do
    user = Wnp::Models::User.create name:"Jordan", email:"good@email.com", password:"cool"
    user_pages = Wnp::Services::UserPages.new user
    page = Wnp::Services::UserPages.new(user).create_page name:"foo-cool"
    get '/p/other', {}, {"rack.session" => {:access_token => user.access_token}}
    assert_equal "Could not find that page", last_response.body 
  end

end
