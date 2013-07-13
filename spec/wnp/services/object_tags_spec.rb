require_relative "../../spec_helper"

describe Wnp::Services::ObjectTags do

  before do
    @page = Wnp::Models::Page.create name:"killer", revision:1
    @object_tags = Wnp::Services::ObjectTags.new(@page)
  end

  def sorted_tag_names
    @object_tags.sorted_tag_names()
  end

  describe "adding" do

    it "should be able to add a page tag" do
      @object_tags.add_tag "cool-house"
      assert @object_tags.has_tag_with_name?("cool-house")
    end

    it "should not add a tag if the name does not validate" do
      @object_tags.add_tag "not a valid name"
      assert_equal [], sorted_tag_names()
    end

    it "should be able to add multiple different tags" do
      @object_tags.add_tag "cool-house"
      @object_tags.add_tag "adam"
      assert_equal ["adam", "cool-house"], sorted_tag_names()
    end

    it "should be not add the same tag more than once" do
      @object_tags.add_tag "cool-house"
      @object_tags.add_tag "cool-house"
      assert_equal ["cool-house"], sorted_tag_names()
    end

    describe "list of page ids associated with tag" do

      # it "should update for each tag" do
      #   @object_tags.add_tag "cool-house"
      #   @object_tags.add_tag "adam"
      #   assert_equal [1], @object_tags.get_page_ids_associated_with_tag("adam")
      #   assert_equal [1], @object_tags.get_page_ids_associated_with_tag("cool-house")
      #   assert_equal [], @object_tags.get_page_ids_associated_with_tag("not-a-tag-with-a-page")
      # end

      # it "should update to show multiple pages associated with same tag" do
      #   object_tags_for_page_4 = Wnp::ObjectTags.new(get_memory_datastore(), 4)
      #   @object_tags.add_tag "cool-house"
      #   object_tags_for_page_4.add_tag "cool-house"
      #   assert_equal [1,4], @object_tags.get_page_ids_associated_with_tag("cool-house")
      # end

    end

  end

  describe "removing" do

    before do
      @object_tags.add_tag "cool-house"
      @object_tags.add_tag "adam"
      assert_equal ["adam", "cool-house"], sorted_tag_names()
    end

    it "should be able to remove a tag" do
      @object_tags.remove_tag "cool-house"
      assert_equal ["adam"], sorted_tag_names()
    end

    it "should not freak out if you try to remove a tag that does not exist" do
      @object_tags.remove_tag "does-not-exist"
      assert_equal ["adam", "cool-house"], sorted_tag_names()
    end

    describe "list of page ids associated with tag" do

      # it "should be updated to remove the only page associated with the tag" do
      #   assert_equal [1], @object_tags.get_page_ids_associated_with_tag("cool-house")
      #   @object_tags.remove_tag "cool-house"
      #   assert_equal [], @object_tags.get_page_ids_associated_with_tag("cool-house")
      # end

      # it "should be updated to remove one of the pages associated with the tag" do
      #   object_tags_for_page_3 = Wnp::ObjectTags.new(get_memory_datastore(), 3)
      #   object_tags_for_page_3.add_tag "cool-house"
      #   assert_equal [1,3], @object_tags.get_page_ids_associated_with_tag("cool-house")
      #   object_tags_for_page_3.remove_tag "cool-house"
      #   assert_equal [1], @object_tags.get_page_ids_associated_with_tag("cool-house")
      # end

    end

  end

end
