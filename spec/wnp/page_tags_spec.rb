require_relative "../spec_helper"

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

    describe "list of page ids associated with tag" do

      it "should update for each tag" do
        @page_tags.add_tag "cool-house"
        @page_tags.add_tag "adam"
        assert_equal [1], @page_tags.get_page_ids_associated_with_tag("adam")
        assert_equal [1], @page_tags.get_page_ids_associated_with_tag("cool-house")
        assert_equal [], @page_tags.get_page_ids_associated_with_tag("not-a-tag-with-a-page")
      end

      it "should update to show multiple pages associated with same tag" do
        page_tags_for_page_4 = Wnp::PageTags.new(get_data(), 4)
        @page_tags.add_tag "cool-house"
        page_tags_for_page_4.add_tag "cool-house"
        assert_equal [1,4], @page_tags.get_page_ids_associated_with_tag("cool-house")
      end

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

    describe "list of page ids associated with tag" do

      it "should be updated to remove the only page associated with the tag" do
        assert_equal [1], @page_tags.get_page_ids_associated_with_tag("cool-house")
        @page_tags.remove_tag "cool-house"
        assert_equal [], @page_tags.get_page_ids_associated_with_tag("cool-house")
      end

      it "should be updated to remove one of the pages associated with the tag" do
        page_tags_for_page_3 = Wnp::PageTags.new(get_data(), 3)
        page_tags_for_page_3.add_tag "cool-house"
        assert_equal [1,3], @page_tags.get_page_ids_associated_with_tag("cool-house")
        page_tags_for_page_3.remove_tag "cool-house"
        assert_equal [1], @page_tags.get_page_ids_associated_with_tag("cool-house")
      end

    end

  end

end
