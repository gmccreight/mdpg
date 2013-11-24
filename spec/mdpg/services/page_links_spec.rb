require_relative "../../spec_helper"

describe PageLinks do

  before do
    @user = create_user

    @zebra_page = Page.create name:"zebra-training",
      text:"page 1"
    @alaska_page = Page.create name:"alaska-crab",
      text:"link to [[mdpgpage:#{@zebra_page.id}]]"

    @user.add_page @zebra_page
    @user.add_page @alaska_page

    @user_pages = UserPages.new(@user)

    @page_links = PageLinks.new(@user)
  end

  describe "internal link representation to user-clickable link" do

    it "should work" do
      assert_equal("link to [zebra-training](/p/zebra-training)",
        @page_links.internal_links_to_user_clickable_links(@alaska_page.text))
    end

  end

  describe "page names to ids" do

    it "should work if page exists" do
      assert_equal("[[mdpgpage:#{@zebra_page.id}]]",
        @page_links.page_name_links_to_ids("[[zebra-training]]"))
    end

    it "should not make change if no such page exists" do
      assert_equal("[[no-such-page]]",
        @page_links.page_name_links_to_ids("[[no-such-page]]"))
    end

  end

end
