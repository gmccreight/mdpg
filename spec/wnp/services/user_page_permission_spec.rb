require_relative "../../spec_helper"

describe Wnp::Services::UserPagePermission do

  before do
    $data_store = get_memory_datastore()
    @data = Wnp::Data.new :memory

    @user1 = create_user 1

    @page1 = create_page
    @page2 = create_page
    @page3 = create_page

    @user1.add_page 1
    @user1.add_page 2
    @user1.remove_page 3

    @user2 = create_user 2

  end

  def can_read? user, page
    Wnp::Services::UserPagePermission.new(user, page).can_read?
  end

  def can_write? user, page
    Wnp::Services::UserPagePermission.new(user, page).can_write?
  end

  describe "owner" do

    it "should be able to read one of their pages" do
      assert can_read?(@user1, @page1)
    end

    it "should be able to write one of their pages" do
      assert can_write?(@user1, @page1)
    end

  end

  describe "unrelated person" do

    it "should not be able to read one of user 1's pages" do
      refute can_read?(@user2, @page1)
    end

    it "should not be able to write one of user 1's pages" do
      refute can_write?(@user2, @page1)
    end

    it "user 1 should not be able to read an unrelated page" do
      refute can_read?(@user1, @page3)
    end

  end

end
