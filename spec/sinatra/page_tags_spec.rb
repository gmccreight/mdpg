require File.expand_path '../sinatra_helper.rb', __FILE__

describe "page_tags" do

  before do
    $data_store = get_memory_datastore()

    @user = User.create name:"Jordan",
      email:"jordan@example.com", password:"cool"
    @other_user = User.create name:"Other",
      email:"other@example.com", password:"other"
    user_pages = UserPages.new @user
    @page = UserPages.new(@user).create_page name:"a-good-page",
      text:"I wish I had something *interesting* to say!"
  end

  def get_tags user, page_name
    get "/p/#{page_name}/tags", {},
      {"rack.session" => {:access_token => user.access_token}}
  end

  def add_tag user, page_name, tag_name
    post "/p/#{page_name}/tags", {:text => tag_name}.to_json,
      {"rack.session" => {:access_token => user.access_token}}
  end

  def delete_tag user, page_name, tag_name
    delete "/p/#{page_name}/tags/#{tag_name}", {},
      {"rack.session" => {:access_token => user.access_token}}
  end

  describe "deleting" do

    before do
      add_tag @user, "a-good-page", "new-1"
    end

    it "should delete an existing tag" do
      assert_equal ["new-1"], ObjectTags.new(@page.reload).sorted_tag_names()
      delete_tag @user, "a-good-page", "new-1"
      assert_equal [], ObjectTags.new(@page.reload).sorted_tag_names()
    end

  end

  describe "getting" do

    before do
      add_tag @user, "a-good-page", "new-1"
    end

    it "should get tags for the page that exists" do
      get_tags @user, "a-good-page"
      array = JSON.parse last_response.body
      assert_equal 1, array.size
      assert_equal "new-1", array[0]["text"]
    end

    it "should not get tags for the page that does not exist" do
      get_tags @user, "a-non-existent-page"
      assert_equal "could not find that page", last_response.body
    end

    it "should not get tags for the page that is not one of yours" do
      get_tags @other_user, "a-good-page"
      assert_equal "could not find that page", last_response.body
    end

  end

  describe "adding" do

    describe "successfully" do

      before do
        add_tag @user, "a-good-page", "new-1"
      end

      it "should return a success message" do
        attrs = JSON.parse last_response.body
        assert attrs.has_key?("success")
        assert_equal "added tag new-1", attrs["success"]
      end

      it "should add the tag to the page" do
        @page.reload
        object_tags = ObjectTags.new(@page)
        assert_equal ["new-1"], object_tags.sorted_tag_names()
      end

      it "should *also* add the page to the user's page_tags" do
        @user.reload
        user_page_tags = UserPageTags.new(@user, @page)
        assert_equal ["new-1"], user_page_tags.get_tags()
      end

    end

    describe "unsuccessfully" do

      it "should fail if the page does not exist" do
        add_tag @user, "a-bad-page", "new-1"
        assert_equal "could not find that page", last_response.body
      end

    end

  end

end
