require_relative "../spec_helper"

require "wnp/page_tags"

require "minitest/autorun"

describe Wnp::PageTags do

  before do
    @page_tags = Wnp::PageTags.new(get_data(), 1)
  end

  describe "adding" do

    it "should be able to add a page tag" do
      @page_tags.add_tag "cool-house"
      assert @page_tags.has_tag?("cool-house")
    end

    it "should not add a tag if the name does not validate" do
      @page_tags.add_tag "not a valid name"
      assert_equal [], @page_tags.get_tags()
    end

    it "should be able to add multiple tags" do
      @page_tags.add_tag "cool-house"
      @page_tags.add_tag "adam"
      assert_equal ["adam", "cool-house"], @page_tags.get_tags()
    end

    it "should be not add the same tag more than once" do
      @page_tags.add_tag "cool-house"
      @page_tags.add_tag "cool-house"
      assert_equal ["cool-house"], @page_tags.get_tags()
    end

  end

  describe "removing" do

    before do
      @page_tags.add_tag "cool-house"
      @page_tags.add_tag "adam"
      assert_equal ["adam", "cool-house"], @page_tags.get_tags()
    end

    it "should be able to remove a tag" do
      @page_tags.remove_tag "cool-house"
      assert_equal ["adam"], @page_tags.get_tags()
    end

    it "should not freak out if you try to remove a tag that does not exist" do
      @page_tags.remove_tag "does-not-exist"
      assert_equal ["adam", "cool-house"], @page_tags.get_tags()
    end

  end

end
