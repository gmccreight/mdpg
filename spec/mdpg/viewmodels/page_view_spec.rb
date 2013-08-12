require_relative "../../spec_helper"

describe PageView do

  before do
    @user = create_user
    @page = Page.create name:"my-bongos",
      text:"This is *bongos*, indeed."
    @page_1_vm = PageView.new(@user, @page)
  end

  def user_1_page_tags
    UserPageTags.new(@user, @page)
  end

  def page_1_tags
    ObjectTags.new(@page)
  end

  describe "rendered html for page" do

    it "should render the page's markdown as html" do
      assert_equal "<p>This is <em>bongos</em>, indeed.</p>\n",
        @page_1_vm.rendered_markdown()
    end

  end

  describe "new tag for page" do

    it "should add a new tag to both page and user" do
      @page_1_vm.add_tag("good-stuff")
      assert page_1_tags.has_tag_with_name?("good-stuff")
      assert user_1_page_tags.has_tag_with_name?("good-stuff")
      assert_equal 1, user_1_page_tags.tag_count("good-stuff")
    end

    it "should be able to remove an existing tag" do
      @page_1_vm.add_tag("good-stuff")
      @page_1_vm.remove_tag("good-stuff")
      refute page_1_tags.has_tag_with_name?("good-stuff")
      refute user_1_page_tags.has_tag_with_name?("good-stuff")
      assert_equal 0, user_1_page_tags.tag_count("good-stuff")
    end

  end

  describe "multiple pages with same tag" do

    before do
      page_2 = Page.create name:"food", text:"foo"
      @page_2_vm = PageView.new(@user, page_2)

      @page_1_vm.add_tag("good-stuff")
      @page_2_vm.add_tag("good-stuff")
    end

    it "should increment the user's tags count to 2" do
      assert_equal 2, user_1_page_tags.tag_count("good-stuff")
    end

  end

  describe "same tag as before" do

    it "should not add the same tag again" do
      @page_1_vm.add_tag("good-stuff")
      assert page_1_tags.has_tag_with_name?("good-stuff")
      assert user_1_page_tags.has_tag_with_name?("good-stuff")
      assert_equal 1, user_1_page_tags.tag_count("good-stuff")

      @page_1_vm.add_tag("good-stuff")
      assert user_1_page_tags.has_tag_with_name?("good-stuff")
      assert_equal 1, user_1_page_tags.tag_count("good-stuff")
    end

  end

  describe "suggested tags" do

    before do
      page_2 = Page.create name:"food", text:"foo"
      @page_2_vm = PageView.new(@user, page_2)

      %w{colour great green gross}.each do |tag|
        @page_1_vm.add_tag tag
      end
      %w{green greed}.each do |tag|
        @page_2_vm.add_tag tag
      end
    end

    it "should find a similar tag from other pages but not this one" do
      assert_equal ["greed"], @page_1_vm.tag_suggestions_for("greet")
    end

    it "should return all the tags, minus the current page's if *" do
      assert_equal %w{colour great gross}, @page_2_vm.tag_suggestions_for("*")
    end

  end

end
