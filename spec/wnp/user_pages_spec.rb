require_relative "../spec_helper"

require "wnp/user_pages"

require "minitest/autorun"

describe Wnp::UserPages do

  before do
    @user = Wnp::User.new(get_data(), 1)
    @env = Wnp::Env.new(get_data(), @user)
    @user_pages = Wnp::UserPages.new(@env, @user)

    user = create_user 1

    create_page 1, :name => "zebra-training", :text => "the text for page 1"
    create_page 2, :name => "alaska-crab", :text => "the text for page 2"

    user.add_page 1
    user.add_page 2
  end

  it "should list the page ids and names sorted by name" do
    assert_equal [[2, "alaska-crab"], [1, "zebra-training"]], @user_pages.page_ids_and_names_sorted_by_name()
  end

  describe "search_content" do

    it "should give a single result if only one page matches" do
      assert_equal ["alaska-crab"], @user_pages.search_content("page 2").map(&:name)
    end

    it "should give multiple results if multiple pages match" do
      assert_equal ["zebra-training", "alaska-crab"], @user_pages.search_content("the text for page").map(&:name)
    end

  end

end
