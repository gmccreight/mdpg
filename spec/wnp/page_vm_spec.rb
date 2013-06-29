require_relative "../spec_helper"

describe Wnp::PageVm do

  before do
    @user = Wnp::User.new(get_data(), 1)
    @env = Wnp::Env.new(get_data(), @user)
    page = Wnp::Page.new(get_data(), 1)
    @page_1_vm = Wnp::PageVm.new(@env, page)
  end

  def user_1_page_tags
    Wnp::Services::UserPageTags.new(get_data(), 1)
  end

  def page_1_tags
    Wnp::PageTags.new(get_data(), 1)
  end

  def page_2_tags
    Wnp::PageTags.new(get_data(), 2)
  end

  describe "new tag for page" do

    it "should add a new tag to both page and user" do
      @page_1_vm.add_tag("good-stuff")
      assert page_1_tags.has_tag?("good-stuff")
      assert user_1_page_tags.has_tag?("good-stuff")
      assert 1, user_1_page_tags.tag_count("good-stuff")
    end

    it "should be able to remove an existing tag" do
      @page_1_vm.add_tag("good-stuff")
      @page_1_vm.remove_tag("good-stuff")
      refute page_1_tags.has_tag?("good-stuff")
      refute user_1_page_tags.has_tag?("good-stuff")
      assert 0, user_1_page_tags.tag_count("good-stuff")
    end

  end

  describe "multiple pages with same tag" do

    before do
      page_2 = Wnp::Page.new(get_data(), 2)
      @page_2_vm = Wnp::PageVm.new(@env, page_2)

      @page_1_vm.add_tag("good-stuff")
      @page_2_vm.add_tag("good-stuff")
    end

    it "should increment the user's tags count to 2" do
      assert 2, user_1_page_tags.tag_count("good-stuff")
    end

  end

  describe "same tag as before" do

    it "should not add the same tag again" do
      @page_1_vm.add_tag("good-stuff")
      assert page_1_tags.has_tag?("good-stuff")
      assert user_1_page_tags.has_tag?("good-stuff")
      assert 1, user_1_page_tags.tag_count("good-stuff")

      @page_1_vm.add_tag("good-stuff")
      assert user_1_page_tags.has_tag?("good-stuff")
      assert 1, user_1_page_tags.tag_count("good-stuff")
    end

  end

end
