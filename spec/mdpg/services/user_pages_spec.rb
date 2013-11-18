require_relative "../../spec_helper"

describe UserPages do

  before do
    @user = create_user

    @zebra_page = Page.create name:"zebra-training",
      text:"the text for page 1"
    @alaska_page = Page.create name:"alaska-crab",
      text:"the text for page 2"

    @user.add_page @zebra_page
    @user.add_page @alaska_page

    @user_pages = UserPages.new(@user)
  end

  describe "adds page to user" do

    before do
      @user_pages = UserPages.new(user)
    end

    let (:user) {
      MiniTest::Mock.new.expect :add_page, true, [Page]
    }

    it "should add the newly created page to the user" do
      page = @user_pages.create_page name:"hello"
      assert_equal "Fixnum", page.id.class.name
      user.verify
    end

    it "should not add the page if it has a bad name" do
      page = @user_pages.create_page name:"Bad Name"
      assert_raises MockExpectationError do
        user.verify
      end
    end

    it "should provide a default 32 character hexcode if name is empty" do
      page = @user_pages.create_page name:""
      assert page.name.size == 32
    end

  end

  describe "delete page" do

    before do
      @user = User.create name:"Jordan"
      @user_pages = UserPages.new(@user)

      @page = @user_pages.create_page name:"hello"

      @user_page_tags = UserPageTags.new(@user, @page)
      @user_page_tags.add_tag "cool-house"

      @page_id = @page.id
      assert_equal "hello", Page.find(@page_id).name
    end

    it "should delete the page" do
      assert Page.find(@page_id)
      @user_pages.delete_page @page.name
      assert_nil Page.find(@page_id)
    end

    it "should delete the association with the user" do
      assert @user_pages.find_page_with_name("hello")
      @user_pages.delete_page @page.name
      assert_nil @user_pages.find_page_with_name("hello")
    end

    it "should remove tag from user if was only on this one page" do
      assert_equal ["cool-house"], @user_page_tags.get_tags()
      @user_pages.delete_page @page.name
      assert_equal [], @user_page_tags.get_tags()
    end

  end

  it "should list the page ids and names sorted by name" do
    expected = [
      [@alaska_page.id, "alaska-crab"],
      [@zebra_page.id, "zebra-training"]
    ]
    assert_equal expected, @user_pages.page_ids_and_names_sorted_by_name()
  end

  describe "page with name" do

    it "should return a page with a matching name" do
      assert_equal "alaska-crab",
        @user_pages.find_page_with_name("alaska-crab").name
    end

    it "should not return a page if the user does not have that page" do
      assert_nil @user_pages.find_page_with_name("non-existent")
    end

  end

  describe "pages_with_text_containing_text" do

    it "should give a single result if only one page matches" do
      assert_equal ["alaska-crab"],
        @user_pages.pages_with_text_containing_text("page 2").map(&:name)
    end

    it "should give multiple results if multiple pages match" do
      assert_equal ["zebra-training", "alaska-crab"],
        @user_pages.pages_with_text_containing_text("the text").map(&:name)
    end

    it "should match in a case-insensitive way" do
      assert_equal ["alaska-crab"],
        @user_pages.pages_with_text_containing_text("Page 2").map(&:name)
    end

  end

  describe "pages_with_names_containing_text" do

    it "should give a single result if only one page matches" do
      assert_equal ["alaska-crab"],
        @user_pages.pages_with_names_containing_text("lask").map(&:name)
    end

    it "should give multiple results if multiple pages match" do
      assert_equal ["zebra-training", "alaska-crab"],
        @user_pages.pages_with_names_containing_text("a").map(&:name)
    end

    it "should match in a case-insensitive way" do
      assert_equal ["alaska-crab"],
        @user_pages.pages_with_names_containing_text("Alaska").map(&:name)
    end

  end

  describe "duplicating a page" do

    before do
      @user = User.create name:"Jordan"
      @user_pages = UserPages.new(@user)

      @page = @user_pages.create_page name:"hello"
      @page.text = "world"
      @page.save

      @user_page_tags = UserPageTags.new @user, @page
      @user_page_tags.add_tag "cool-house"

      @page_id = @page.id
      assert_equal "hello", Page.find(@page_id).name
    end

    it "should duplicate a page, including the text and tags" do
      new_page = @user_pages.duplicate_page "hello"
      assert_equal "hello-2", new_page.name
      assert_equal "world", new_page.text

      user_page_tags = UserPageTags.new @user, new_page
      assert_equal ["cool-house"], user_page_tags.
        tags_for_page(new_page).map{|x| x.name}
    end

    it "should only duplicate the page's tags, not all page tags" do
      different_page = @user_pages.create_page name:"different-page"
      user_a_different_page_tags = UserPageTags.new(@user, different_page)
      user_a_different_page_tags.add_tag "tag-on-different-page"

      new_page = @user_pages.duplicate_page "hello"

      user_page_tags = UserPageTags.new @user, new_page
      assert_equal ["cool-house"], user_page_tags.
        tags_for_page(new_page).map{|x| x.name}
    end

    it "should increment if page name taken" do
      @user_pages.create_page name:"hello-2"
      new_page = @user_pages.duplicate_page "hello"
      assert_equal "hello-3", new_page.name
    end

    it "should increment if page name taken - multiple times" do
      @user_pages.create_page name:"hello-2"
      @user_pages.create_page name:"hello-3"
      new_page = @user_pages.duplicate_page "hello"
      assert_equal "hello-4", new_page.name
    end

  end

end
