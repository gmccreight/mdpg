require "wnp/page_permission"

require "minitest/autorun"

describe Wnp::PagePermission do

  before do
    @data = Wnp::Data.new :memory

    @data.set "userdata-1-page-ids", [1,2]
    @data.set "userdata-2-page-ids", []
    @data.set "pagedata-1-0", {:name => "owned-by-user-1"}
    @data.set "pagedata-2-0", {:name => "also-owned-by-user-1"}
    @data.set "pagedata-3-0", {:name => "not-owned-by-user-1"}

    @user1 = Wnp::User.new(@data, 1)
    @user2 = Wnp::User.new(@data, 2)

    @page1 = Wnp::Page.new(@data, 1)
    @page2 = Wnp::Page.new(@data, 2)
    @page3 = Wnp::Page.new(@data, 3)
  end

  def can_view?(user, page)
    Wnp::PagePermission.new(user, page).can_view?
  end

  def can_edit?(user, page)
    Wnp::PagePermission.new(user, page).can_edit?
  end

  describe "owner" do

    it "should be able to view one of their pages" do
      assert can_view?(@user1, @page1)
    end

    it "should be able to edit one of their pages" do
      assert can_edit?(@user1, @page1)
    end

  end

  describe "unrelated person" do

    it "should not be able to view one of user 1's pages" do
      refute can_view?(@user2, @page1)
    end

    it "should not be able to edit one of user 1's pages" do
      refute can_edit?(@user2, @page1)
    end

    it "user 1 should not be able to view an unrelated page" do
      refute can_view?(@user1, @page3)
    end

  end

end
