# frozen_string_literal: true
require_relative '../../spec_helper'

describe UserRecentPages do
  before do
    $data_store = memory_datastore
    @user = User.create name: 'John',
                        email: 'good@email.com', password: 'cool'
  end

  describe 'edited' do
    before do
      add_some_recent_pages
    end

    def add_some_recent_pages
      @page_1 = create_page
      UserRecentPages.new(@user).add_to_recent_edited_pages_list @page_1
      @page_2 = create_page
      UserRecentPages.new(@user).add_to_recent_edited_pages_list @page_2
      @page_3 = create_page
      UserRecentPages.new(@user).add_to_recent_edited_pages_list @page_3
    end

    def page_ids_should_be(expected)
      assert_equal expected, @user.recent_edited_page_ids
    end

    it 'should add a second recent page after the first one' do
      page_ids_should_be [@page_3.id, @page_2.id, @page_1.id]
    end

    it 'should move a newly added repeat page to beginning of the list' do
      UserRecentPages.new(@user).add_to_recent_edited_pages_list @page_2
      page_ids_should_be [@page_2.id, @page_3.id, @page_1.id]
    end
  end
end
