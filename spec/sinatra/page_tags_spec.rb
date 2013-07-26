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

  def get_tags
    get "/p/a-good-page/tags", {},
      {"rack.session" => {:access_token => @user.access_token}}
  end

  def add_tag tag_name
    post "/p/a-good-page/tags", {:text => tag_name}.to_json,
      {"rack.session" => {:access_token => @user.access_token}}
  end

  describe "getting" do

    it "should get tags for the page" do
      add_tag "new-tag"
      get_tags
      array = JSON.parse last_response.body
      assert_equal 1, array.size
      assert_equal "new-tag", array[0]["text"]
    end

  end

  describe "adding" do

    it "should add a tag to the page" do
      add_tag "new-tag"
      attrs = JSON.parse last_response.body
      assert attrs.has_key?("success")
      assert_equal "added tag new-tag", attrs["success"]

      @page.reload
      object_tags = Wnp::Services::ObjectTags.new(@page)
      assert_equal ["new-tag"], object_tags.sorted_tag_names()
    end

  end

end
