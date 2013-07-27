require_relative "../../spec_helper"

describe PageView do

  before do
    @user = create_user
    @page = Wnp::Models::Page.create name:"my-bongos",
      text:"This is *bongos*, indeed."
    @page_1_vm = PageView.new(@user, @page)
  end

  def user_1_page_tags
    Wnp::Services::UserPageTags.new(@user, @page)
  end

  def page_1_tags
    Wnp::Services::ObjectTags.new(@page)
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
      page_2 = Wnp::Models::Page.create name:"food", text:"foo"
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

end
