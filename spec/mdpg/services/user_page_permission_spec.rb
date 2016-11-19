# frozen_string_literal: true
require_relative '../../spec_helper'

describe UserPagePermission do
  before do
    $data_store = memory_datastore

    @user_1 = create_user

    @page_1 = create_page
    @page_2 = create_page
    @page_3 = create_page

    @user_1.add_page @page_1
    @user_1.add_page @page_2
    @user_1.remove_page @page_3

    @user_2 = create_user
  end

  def can_read?(user, page)
    UserPagePermission.new(user, page).can_read?
  end

  def can_write?(user, page)
    UserPagePermission.new(user, page).can_write?
  end

  describe 'owner' do
    it 'should be able to read one of their pages' do
      assert can_read?(@user_1, @page_1)
    end

    it 'should be able to write one of their pages' do
      assert can_write?(@user_1, @page_1)
    end
  end

  describe 'unrelated person' do
    it "should not be able to read one of user 1's pages" do
      refute can_read?(@user_2, @page_1)
    end

    it "should not be able to write one of user 1's pages" do
      refute can_write?(@user_2, @page_1)
    end

    it 'user 1 should not be able to read an unrelated page' do
      refute can_read?(@user_1, @page_3)
    end
  end
end
