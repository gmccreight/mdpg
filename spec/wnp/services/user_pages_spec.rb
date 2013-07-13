require_relative "../../spec_helper"

describe Wnp::Services::UserPages do

  before do
    @user = Wnp::Models::User.create name:"John", email:"good@email.com", password:"cool"

    @zebra_page = Wnp::Models::Page.create name:"zebra-training", text:"the text for page 1"
    @alaska_page = Wnp::Models::Page.create name:"alaska-crab", text:"the text for page 2"

    @user.add_page @zebra_page.id
    @user.add_page @alaska_page.id

    @user_pages = Wnp::Services::UserPages.new(@user)
  end

  it "should list the page ids and names sorted by name" do
    assert_equal [[@alaska_page.id, "alaska-crab"], [@zebra_page.id, "zebra-training"]], @user_pages.page_ids_and_names_sorted_by_name()
  end

  describe "pages_with_text_containing_text" do

    it "should give a single result if only one page matches" do
      assert_equal ["alaska-crab"], @user_pages.pages_with_text_containing_text("page 2").map(&:name)
    end

    it "should give multiple results if multiple pages match" do
      assert_equal ["zebra-training", "alaska-crab"], @user_pages.pages_with_text_containing_text("the text for page").map(&:name)
    end

  end

  describe "pages_with_names_containing_text" do

    it "should give a single result if only one page matches" do
      assert_equal ["alaska-crab"], @user_pages.pages_with_names_containing_text("lask").map(&:name)
    end

    it "should give multiple results if multiple pages match" do
      assert_equal ["zebra-training", "alaska-crab"], @user_pages.pages_with_names_containing_text("a").map(&:name)
    end

  end

end
