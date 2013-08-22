require File.expand_path '../sinatra_helper.rb', __FILE__

describe "page" do

  before do
    $data_store = get_memory_datastore()

    @user = User.create name:"Jordan",
      email:"jordan@example.com", password:"cool"
    user_pages = UserPages.new @user
    UserPages.new(@user).create_page name:"original-good-page-name",
      text:"I wish I had something *interesting* to say!"
  end

  def authenticated_session
    {"rack.session" => {:access_token => @user.access_token}}
  end

  def get_page name
    get "/p/#{name}", {}, authenticated_session
  end

  def update_page name, text
    post "/p/#{name}/update", {:text => text}, authenticated_session
  end

  def delete_page name
    post "/p/#{name}/delete", {}, authenticated_session
  end

  def rename_page name, new_name
    post "/p/#{name}/rename", {:new_name => new_name}, authenticated_session
  end

  describe "viewing" do

    it "should get a page that is owned by the user" do
      get_page "original-good-page-name"
      expected = "<p>I wish I had something <em>interesting</em> to say!</p>\n"
      assert last_response.body.include? expected
    end

    it "should not get a page if the user does not have a page by that name" do
      get_page "not-one-of-the-users-pages"
      assert_equal "could not find that page", last_response.body 
    end

    it "should redirect to login form if the access_token is invalid" do
      get '/p/other', {}, {"rack.session" => {:access_token => "some nonsense"}}
      follow_redirect!
      assert last_response.body.include? "Please login"
    end

  end

  describe "updating" do

    it "should update the text of a page and redirect back to the page" do
      update_page "original-good-page-name", "some *new* text"
      follow_redirect!
      assert last_request.url.include? "/p/original-good-page-name"
      assert last_response.body.include? "some <em>new</em> text"
    end

    it "should fail to update a page if the page does not exist" do
      update_page "not-original-good-page-name", "some text"
      assert_equal "could not find that page", last_response.body
    end

  end

  describe "rename" do

    it "should rename a page and redirect you to it" do
      rename_page "original-good-page-name", "a-renamed-page"
      follow_redirect!
      assert last_request.url.include? "/p/a-renamed-page"
      assert last_response.body.include? "I wish I had"
    end

    it "should not rename a page if the new name is bad" do
      rename_page "original-good-page-name", "BAD Name"
      follow_redirect!
      assert last_request.url.include? "/p/original-good-page-name"
      assert last_response.body.include? "I wish I had"
    end

    it "should not rename a page to a name of another page that already exists" do
      UserPages.new(@user).create_page name:"already-taken-page-name", text:""
      rename_page "original-good-page-name", "already-taken-page-name"
      assert_equal "a page with that name already exists", last_response.body 
    end

  end

  describe "deleting" do

    it "should delete a page and redirect back to the home page" do
      delete_page "original-good-page-name"
      follow_redirect!
      assert last_response.body.include? "Hello, "
      get_page "original-good-page-name"
      assert_equal "could not find that page", last_response.body 
    end

  end

end
