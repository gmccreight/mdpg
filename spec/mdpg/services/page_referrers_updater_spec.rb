require_relative '../../spec_helper'

describe PageReferrersUpdater do
  before do
    $data_store = memory_datastore
    @user = create_user
    @page = create_page
    @referrers_updater = PageReferrersUpdater.new
  end

  def add(page_ids)
    page_ids.each do |page_id|
      @referrers_updater.add_page_id_to_referrers(page_id, @page)
    end
  end

  def remove(page_ids)
    page_ids.each do |page_id|
      @referrers_updater.remove_page_id_from_referrers(page_id, @page)
    end
  end

  describe 'adding' do
    it 'should work even if list is nil (upgrade)' do
      @page.referring_page_ids = nil
      add [21]
      assert_equal @page.referring_page_ids, [21]
    end

    describe 'to an empy list' do
      before do
        assert_equal @page.referring_page_ids, []
      end

      it 'should add a referrer if there are none' do
        add [21]
        assert_equal @page.referring_page_ids, [21]
      end

      it 'should keep new page ids ordered on insertion' do
        add [21, 20]
        assert_equal @page.referring_page_ids, [20, 21]
      end

      it 'should not double-insert page ids' do
        add [20, 21]
        add [20]
        assert_equal @page.referring_page_ids, [20, 21]
      end
    end
  end

  describe 'removing' do
    it 'should remove a single one' do
      add [20, 21, 22]
      remove [21]
      assert_equal @page.referring_page_ids, [20, 22]
    end

    it 'should make it empty if you remove the last one' do
      add [20, 21, 22]
      remove [20, 21, 22]
      assert_equal @page.referring_page_ids, []
    end

    it 'should not freak out if you try to remove a non-existing one' do
      add [20, 21, 22]
      remove [100]
      assert_equal @page.referring_page_ids, [20, 21, 22]
    end

    it 'should not freak out if you try to remove something from empty one' do
      @page.referring_page_ids = []
      @page.save
      remove [80]
      assert_equal @page.referring_page_ids, []
    end

    it 'should not freak out if you try to remove something from a nil' do
      @page.referring_page_ids = nil
      @page.save
      remove [80]
      assert_equal @page.referring_page_ids, []
    end
  end
end
