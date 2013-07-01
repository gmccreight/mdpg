require_relative "../spec_helper"

describe Wnp::UserPages do

  before do
    @user = Wnp::User.new(get_memory_datastore(), 1)
    @env = Wnp::Env.new(get_memory_datastore(), @user)
    @user_pages = Wnp::UserPages.new(@env, @user)

    user = create_user 1

    create_page :name => "zebra-training", :text => "the text for page 1"
    create_page :name => "alaska-crab", :text => "the text for page 2"

    user.add_page 1
    user.add_page 2
  end

  it "should list the page ids and names sorted by name" do
    assert_equal [[2, "alaska-crab"], [1, "zebra-training"]], @user_pages.page_ids_and_names_sorted_by_name()
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
