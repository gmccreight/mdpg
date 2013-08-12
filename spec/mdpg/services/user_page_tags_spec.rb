require_relative "../../spec_helper"

describe UserPageTags do

  before do
    $data_store = get_memory_datastore
    @user = create_user
    @page = create_page
    @user_page_tags = UserPageTags.new(@user, @page)
  end

  describe "adding" do

    it "should be able to add a user tag" do
      @user_page_tags.add_tag "cool-house"
      assert @user_page_tags.has_tag_with_name?("cool-house")
    end

    it "should not add a tag if the name does not validate" do
      @user_page_tags.add_tag "not a valid name"
      assert_equal [], @user_page_tags.get_tags()
    end

    it "should be able to add multiple tags" do
      @user_page_tags.add_tag "cool-house"
      @user_page_tags.add_tag "adam"
      assert_equal ["adam", "cool-house"], @user_page_tags.get_tags()
    end

    it "should be not add the same tag more than once" do
      @user_page_tags.add_tag "cool-house"
      @user_page_tags.add_tag "cool-house"
      assert_equal ["cool-house"], @user_page_tags.get_tags()
    end

  end

  describe "removing" do

    before do
      @user_page_tags.add_tag "cool-house"
      @user_page_tags.add_tag "adam"
      assert_equal ["adam", "cool-house"], @user_page_tags.get_tags()
    end

    it "should be able to remove a tag" do
      @user_page_tags.remove_tag "cool-house"
      assert_equal ["adam"], @user_page_tags.get_tags()
    end

    it "should not freak out if you try to remove a non-existent tag" do
      @user_page_tags.remove_tag "does-not-exist"
      assert_equal ["adam", "cool-house"], @user_page_tags.get_tags()
    end

  end

  describe "searching" do

    before do
      %w{color trombone green colour}.each{|x| @user_page_tags.add_tag x}
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

  describe "getting the pages that have been tagged" do

    before do
      %w{color trombone green colour}.each{|x| @user_page_tags.add_tag x}
      @another_page = create_page
      @user_page_tags = UserPageTags.new(@user, @another_page)
      %w{green}.each{|x| @user_page_tags.add_tag x}
    end

    def page_ids_for_tag tag
      @user_page_tags.get_pages_for_tag_with_name(tag).map{|page| page.id}
    end

    it "should get pages for a tag that was added to multiple pages" do
      assert_equal [@page.id, @another_page.id], page_ids_for_tag("green")
    end

    it "should get one page for a tag that was added to one page" do
      assert_equal [@page.id], page_ids_for_tag("trombone")
    end

    it "should get no pages for a tag that has been added to no pages" do
      assert_equal [], page_ids_for_tag("not-a-tag-with-a-page")
    end

  end

end
