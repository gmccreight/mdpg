require_relative "../spec_helper"

require "wnp/user_tags"

require "minitest/autorun"

describe Wnp::UserTags do

  before do
    @user_tags = Wnp::UserTags.new(get_data(), 1)
  end

  describe "adding" do

    it "should be able to add a user tag" do
      @user_tags.add_tag "cool-house"
      assert @user_tags.has_tag?("cool-house")
    end

    it "should not add a tag if the name does not validate" do
      @user_tags.add_tag "not a valid name"
      assert_equal [], @user_tags.get_tags()
    end

    it "should be able to add multiple tags" do
      @user_tags.add_tag "cool-house"
      @user_tags.add_tag "adam"
      assert_equal ["adam", "cool-house"], @user_tags.get_tags()
    end

    it "should be not add the same tag more than once" do
      @user_tags.add_tag "cool-house"
      @user_tags.add_tag "cool-house"
      assert_equal ["cool-house"], @user_tags.get_tags()
    end

  end

  describe "removing" do

    before do
      @user_tags.add_tag "cool-house"
      @user_tags.add_tag "adam"
      assert_equal ["adam", "cool-house"], @user_tags.get_tags()
    end

    it "should be able to remove a tag" do
      @user_tags.remove_tag "cool-house"
      assert_equal ["adam"], @user_tags.get_tags()
    end

    it "should not freak out if you try to remove a tag that does not exist" do
      @user_tags.remove_tag "does-not-exist"
      assert_equal ["adam", "cool-house"], @user_tags.get_tags()
    end

  end

end
