require_relative '../../spec_helper'

describe PageRefersToUpdater do
  before do
    $data_store = memory_datastore
    @user = create_user
    @user_pages = UserPages.new(@user)
  end

  describe 'partial includes' do
    it 'should set up referrals between included pages' do
      ident = 'alsdkjfwijalkfjlsdkfj'

      other_text = (<<-EOF).gsub(/^ +/, '')
        something that we're talking about
        with [[#important-idea:#{ident}]]
        John James said: "this is an important idea"
        [[#important-idea:#{ident}]]
      EOF
      other_page = @user_pages.create_page name: 'other-page', text: other_text

      this_text = (<<-EOF).gsub(/^ +/, '')
        I'm including this:
        [[other-page#important-idea]]
        because it is so important
      EOF
      page = @user_pages.create_page name: 'this-page', text: this_text

      assert_equal [other_page.id], page.reload.refers_to_page_ids
      assert_equal [page.id], other_page.reload.referring_page_ids
    end
  end

  describe 'partial includes AND page links' do
    it 'should work with both types of referrals to other pages' do
      ident = 'alsdkjfwijalkfjlsdkfj'

      other_page_1_text = (<<-EOF).gsub(/^ +/, '')
        something that we're talking about
        with [[#important-idea:#{ident}]]
        John James said: "this is an important idea"
        [[#important-idea:#{ident}]]
      EOF
      other_page_1 = @user_pages.create_page name: 'other-page-1',
        text: other_page_1_text

      other_page_2 = @user_pages.create_page name: 'other-page-2',
        text: 'just some text'

      this_text = (<<-EOF).gsub(/^ +/, '')
        I'm including this:
        [[other-page-1#important-idea]]
        because it is so important.

        I'm also going to link to the same page [[other-page-1]]

        And also a different page [[other-page-2]]
      EOF
      page = @user_pages.create_page name: 'this-page', text: this_text

      assert_equal [other_page_1.id, other_page_2.id],
        page.reload.refers_to_page_ids

      assert_equal [page.id], other_page_1.reload.referring_page_ids
      assert_equal [page.id], other_page_2.reload.referring_page_ids
    end
  end
end
