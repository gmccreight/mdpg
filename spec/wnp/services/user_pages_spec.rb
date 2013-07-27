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
      @user = User.create name:"Jordan"
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

  end

end
