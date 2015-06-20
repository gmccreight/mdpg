require_relative '../../spec_helper'

describe PageLinks do
  before do
    $data_store = memory_datastore
    @user = create_user

    @zebra_page = Page.create name: 'zebra-training',
      text: 'page 1'
    @alaska_page = Page.create name: 'alaska-crab',
      text: "link to [[mdpgpage:#{@zebra_page.id}]]"

    @user.add_page @zebra_page
    @user.add_page @alaska_page

    @user_pages = UserPages.new(@user)

    @page_links = PageLinks.new(@user)
  end

  describe 'internal links to user-clickable link' do
    it 'should work' do
      assert_equal('link to [zebra-training](/p/zebra-training)',
        @page_links.internal_links_to_user_clickable_links(@alaska_page.text))
    end
  end

  describe 'internal links to page name links for editing' do
    it 'should work' do
      link_text = "hey there [[mdpgpage:#{@zebra_page.id}]] foo"
      assert_equal('hey there [[zebra-training]] foo',
        @page_links.internal_links_to_page_name_links_for_editing(link_text))
    end
  end

  describe 'page names to ids' do
    it 'should work if page exists' do
      assert_equal("[[mdpgpage:#{@zebra_page.id}]]",
        @page_links.page_name_links_to_ids('[[zebra-training]]'))
    end

    describe 'where the page does not exist' do
      it 'should not make change if no such page exists' do
        assert_equal('[[no-such-page]]',
          @page_links.page_name_links_to_ids('[[no-such-page]]'))
      end

      it 'should create a page if the link had new- at the start' do
        assert_match(/\[\[mdpgpage:\d+\]\]/,
          @page_links.page_name_links_to_ids('[[new-a-great-page]]'))
        new_page_id = @user_pages.find_page_with_name('a-great-page').id
        assert_equal 'a-great-page', Page.find(new_page_id).name
      end
    end
  end

  describe 'ids of the links' do
    it 'should return empty array if nothing' do
      assert_equal([], @page_links.get_page_ids('what foo'))
    end

    it 'should return a single page id' do
      assert_equal([@zebra_page.id],
        @page_links.get_page_ids("what [[mdpgpage:#{@zebra_page.id}]] foo"))
    end

    it 'should return multiple page ids' do
      text = "[[mdpgpage:#{@alaska_page.id}]] [[mdpgpage:#{@zebra_page.id}]]"
      assert_equal([@zebra_page.id, @alaska_page.id].sort,
                   @page_links.get_page_ids(text).sort)
    end
  end
end
