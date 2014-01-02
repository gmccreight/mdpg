require File.expand_path '../sinatra_helper.rb', __FILE__

describe "page" do

  before do
    $data_store = get_memory_datastore()

    @user = User.create name:"Jordan",
      email:"jordan@example.com", password:"cool"
    user_pages = UserPages.new @user
    @page = UserPages.new(@user).create_page name:"original-good-page-name",
      text:"I have something *interesting* to say!"
  end

  def get_page name
    get "/p/#{name}", {}, authenticated_session(@user)
  end

  def edit_page name
    get "/p/#{name}/edit", {}, authenticated_session(@user)
  end

  def update_page name, text
    post "/p/#{name}/update", {:text => text}, authenticated_session(@user)
  end

  def delete_page name
    post "/p/#{name}/delete", {}, authenticated_session(@user)
  end

  def rename_page name, new_name
    post "/p/#{name}/rename", {:new_name => new_name},
      authenticated_session(@user)
  end

  describe "viewing" do

    it "should get a page that is owned by the user" do
      get_page "original-good-page-name"
      expected = "<p>I have something <em>interesting</em> to say!</p>\n"
      assert last_response.body.include? expected
    end

    it "should not get a page if user has no page with that name" do
      get_page "not-one-of-the-users-pages"
      assert_equal "could not find that page", last_response.body
    end

    it "should redirect to login form if no cookie" do
      get '/p/other', {}
      follow_redirect!
      assert last_response.body.include? "Please login"
    end

  end

  describe "viewing via the public share link" do

    def get_shared_page long_readonly_token
      get "/s/#{long_readonly_token}", {}, authenticated_session(@user)
    end

    it "should be able to see the page with the right token" do
      token = Page.find(1).readonly_sharing_token
      assert_equal token.size, 32

      get_shared_page token
      expected = "<p>I have something <em>interesting</em> to say!</p>\n"
      assert last_response.body.include? expected
    end

    it "should not be able to see the page with an incorrect token" do
      get_shared_page "not-right-token-not-right-token-not-right-token"
      follow_redirect!
      follow_redirect!
      assert last_response.body.include? "Please login"
    end

  end

  describe "updating" do

    it "should update the text of a page and redirect back to the page" do
      update_page "original-good-page-name", "some *new* text"
      follow_redirect_with_authenticated_user!(@user)
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
      follow_redirect_with_authenticated_user!(@user)
      assert last_request.url.include? "/p/a-renamed-page"
      assert last_response.body.include? "I have"
    end

    it "should not rename a page if the new name is bad" do
      rename_page "original-good-page-name", "BAD Name"
      follow_redirect_with_authenticated_user!(@user)
      assert last_request.url.include? "/p/original-good-page-name"
      assert last_response.body.include? "I have"
    end

    it "should not rename a page to an existing page's name" do
      UserPages.new(@user).create_page name:"already-taken-page-name", text:""
      rename_page "original-good-page-name", "already-taken-page-name"
      assert_equal "a page with that name already exists", last_response.body
    end

  end

  describe "rename_sharing_token" do

    def rename_sharing_token type, new_token
      post "/p/#{@page.name}/rename_sharing_token",
        {:token_type => type, :new_token => new_token},
        authenticated_session(@user)
    end

    it "should rename a readonly token" do
      rename_sharing_token "readonly", "new-readonly-token"
      @page.reload
      assert_equal "new-readonly-token", @page.readonly_sharing_token
      follow_redirect_with_authenticated_user!(@user)
      assert last_request.url.include? "/p/#{@page.name}"
    end

    it "should rename a readwrite token" do
      rename_sharing_token "readwrite", "new-readwrite-token"
      @page.reload
      assert_equal "new-readwrite-token", @page.readwrite_sharing_token
      follow_redirect_with_authenticated_user!(@user)
      assert last_request.url.include? "/p/#{@page.name}"
    end

    it "should not rename token if another already has that token" do
      rename_sharing_token "readonly", @page.readonly_sharing_token
      assert_equal "a page with that token already exists", last_response.body
    end

    it "should not rename token if the provided token is too short" do
      rename_sharing_token "readonly", "s"
      assert_equal "too_short", last_response.body
    end

  end

  describe "deleting" do

    it "should delete a page and redirect back to the home page" do
      delete_page "original-good-page-name"
      follow_redirect_with_authenticated_user!(@user)
      assert last_response.body.include? "Hello, "
      get_page "original-good-page-name"
      assert_equal "could not find that page", last_response.body
    end

  end

  describe "editing" do

    it "should render the edit page with the unprocessed text" do
      edit_page "original-good-page-name"
      expected = "I have something *interesting* to say!"
      assert last_response.body.include? expected
    end

  end

  describe "recently viewed of edited pages" do

    it "should show the recently-created page" do
      get "/page/recent", {}, authenticated_session(@user)
      expected = "original-good-page-name"
      assert last_response.body.include? expected
    end

  end

end
