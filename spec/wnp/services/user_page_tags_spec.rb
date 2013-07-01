require_relative "../../spec_helper"

describe Wnp::Services::UserPageTags do

  before do
    @user_page_tags = Wnp::Services::UserPageTags.new(get_memory_datastore(), 1)
  end

  describe "adding" do

    it "should be able to add a user tag" do
      @user_page_tags.add_tag "cool-house", 1
      assert @user_page_tags.has_tag?("cool-house")
    end

    it "should not add a tag if the name does not validate" do
      @user_page_tags.add_tag "not a valid name", 1
      assert_equal [], @user_page_tags.get_tags()
    end

    it "should be able to add multiple tags" do
      @user_page_tags.add_tag "cool-house", 1
      @user_page_tags.add_tag "adam", 1
      assert_equal ["adam", "cool-house"], @user_page_tags.get_tags()
    end

    it "should be not add the same tag more than once" do
      @user_page_tags.add_tag "cool-house", 1
      @user_page_tags.add_tag "cool-house", 1
      assert_equal ["cool-house"], @user_page_tags.get_tags()
    end

  end

  describe "removing" do

    before do
      @user_page_tags.add_tag "cool-house", 1
      @user_page_tags.add_tag "adam", 1
      assert_equal ["adam", "cool-house"], @user_page_tags.get_tags()
    end

    it "should be able to remove a tag" do
      @user_page_tags.remove_tag "cool-house", 1
      assert_equal ["adam"], @user_page_tags.get_tags()
    end

    it "should not freak out if you try to remove a tag that does not exist" do
      @user_page_tags.remove_tag "does-not-exist", 1
      assert_equal ["adam", "cool-house"], @user_page_tags.get_tags()
    end

  end

  describe "searching" do

    before do
      %w{color trombone green colour}.each{|x| @user_page_tags.add_tag x, 1}
    end

    it "should find all tags that are relatively closely related" do
      assert_equal ["color", "colour"], @user_page_tags.search("color")
    end

    it "should even find tags that are not too closely related" do
      assert_equal ["green"], @user_page_tags.search("great")
    end

    it "should not return any results if no matches" do
      assert_equal [], @user_page_tags.search("what")
    end

  end


end
