require File.expand_path '../sinatra_helper.rb', __FILE__

describe "page_tags" do

  before do
    $data_store = get_memory_datastore()

    @user = Wnp::Models::User.create name:"Jordan",
      email:"jordan@example.com", password:"cool"
    user_pages = Wnp::Services::UserPages.new @user
    @page = Wnp::Services::UserPages.new(@user).create_page name:"a-good-page",
      text:"I wish I had something *interesting* to say!"
  end

  def get_tags page_name
    get "/p/#{page_name}/tags", {},
      {"rack.session" => {:access_token => @user.access_token}}
  end

  def add_tag page_name, tag_name
    post "/p/#{page_name}/tags", {:text => tag_name}.to_json,
      {"rack.session" => {:access_token => @user.access_token}}
  end

  describe "getting" do

    it "should get tags for the page" do
      add_tag "a-good-page", "new-tag"
      get_tags "a-good-page"
      array = JSON.parse last_response.body
      assert_equal 1, array.size
      assert_equal "new-tag", array[0]["text"]
    end

  end

  describe "adding" do

    before do
      add_tag "a-good-page", "new-tag"
    end

    it "should return a success message" do
      attrs = JSON.parse last_response.body
      assert attrs.has_key?("success")
      assert_equal "added tag new-tag", attrs["success"]
    end

    it "should add the tag to the page" do
      @page.reload
      object_tags = Wnp::Services::ObjectTags.new(@page)
      assert_equal ["new-tag"], object_tags.sorted_tag_names()
    end

    it "should *also* add the page to the user's page_tags" do
      @user.reload
      user_page_tags = Wnp::Services::UserPageTags.new(@user, @page)
      assert_equal ["new-tag"], user_page_tags.get_tags()
    end

  end

end
