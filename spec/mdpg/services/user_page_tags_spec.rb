require_relative '../../spec_helper'

describe UserPageTags do

  before do
    $data_store = get_memory_datastore
    @user = create_user
    @page = create_page
    @user_page_tags = UserPageTags.new(@user, @page)
  end

  describe 'adding' do

    it 'should be able to add a user tag' do
      @user_page_tags.add_tag 'cool-house'
      assert @user_page_tags.has_tag_with_name?('cool-house')
    end

    it 'should not add a tag if the name does not validate' do
      @user_page_tags.add_tag 'not a valid name'
      assert_equal [], @user_page_tags.get_tag_names
    end

    it 'should be able to add multiple tags' do
      @user_page_tags.add_tag 'cool-house'
      @user_page_tags.add_tag 'adam'
      assert_equal ['adam', 'cool-house'], @user_page_tags.get_tag_names
    end

    it 'should be not add the same tag more than once' do
      @user_page_tags.add_tag 'cool-house'
      @user_page_tags.add_tag 'cool-house'
      assert_equal ['cool-house'], @user_page_tags.get_tag_names
    end

  end

  describe 'changing' do

    before do
      @user_page_tags.add_tag 'cool'
      @user_page_tags.add_tag 'adam'
    end

    it 'should be able to change to a tag name that does not already exist' do
      assert @user_page_tags.change_tag 'adam', 'henry'
      assert_equal ['cool', 'henry'], @user_page_tags.get_tag_names
      assert_equal ['cool', 'henry'], ObjectTags.new(@page).sorted_tag_names
    end

    it 'should be unable to change to a tag name that already exists' do
      refute @user_page_tags.change_tag 'adam', 'cool'
      assert_equal ['adam', 'cool'], @user_page_tags.get_tag_names
    end

    describe 'bulk' do

      before do
        @page_2 = create_page
        @user_page_tags_2 = UserPageTags.new(@user, @page_2)
        @user_page_tags_2.add_tag 'adam'
      end

      it 'should be able to change the tags associated with multiple pages' do
        UserPageTags.new(@user, nil).change_tag_for_all_pages('adam', 'hello')
        assert_equal ['cool', 'hello'], @user_page_tags.get_tag_names
        assert_equal ['cool', 'hello'],
          ObjectTags.new(@page.reload).sorted_tag_names
        assert_equal ['hello'],
          ObjectTags.new(@page_2.reload).sorted_tag_names
      end

    end

  end

  describe 'removing' do

    before do
      @user_page_tags.add_tag 'cool-house'
      @user_page_tags.add_tag 'adam'
      assert_equal ['adam', 'cool-house'], @user_page_tags.get_tag_names
    end

    it 'should be able to remove a tag' do
      @user_page_tags.remove_tag 'cool-house'
      assert_equal ['adam'], @user_page_tags.get_tag_names
    end

    it 'should not freak out if you try to remove a non-existent tag' do
      @user_page_tags.remove_tag 'does-not-exist'
      assert_equal ['adam', 'cool-house'], @user_page_tags.get_tag_names
    end

  end

  describe 'searching' do

    before do
      %w{color jazz green colour}.each{|x| @user_page_tags.add_tag x}
    end

    it 'should find all tags that are relatively closely related' do
      assert_equal ['color', 'colour'], @user_page_tags.search('color')
    end

    it 'should even find tags that are not too closely related' do
      assert_equal ['green'], @user_page_tags.search('great')
    end

    it 'should not return any results if no matches' do
      assert_equal [], @user_page_tags.search('what')
    end

  end

  describe 'counting' do

    before do
      %w{green color swimming}.each{|x| @user_page_tags.add_tag x}

      another_page = create_page
      user_another_page_tags = UserPageTags.new(@user, another_page)
      %w{green color jazz yeti}.each{|x| user_another_page_tags.add_tag x}

      third_page_tags = UserPageTags.new(@user, create_page)
      %w{green color jazz drums assets}.each{|x| third_page_tags.add_tag x}
    end

    it 'should return associated tags sorted by count, not including self' do
      associated_tags = @user_page_tags.sorted_associated_tags('green')
      target = [
        ['jazz', 2], ['assets', 1], ['drums', 1], ['yeti', 1]
      ]
      assert_equal target, associated_tags
    end

    it 'should not return any tag names already associated with page' do
      associated_tags = @user_page_tags.sorted_associated_tags('green')
      tag_names = associated_tags.map{|x| x[0]}

      assert tag_names.include?('jazz')
      assert tag_names.include?('assets')

      refute tag_names.include?('color')
      refute tag_names.include?('swimming')
    end

  end

  describe 'getting the pages that have been tagged' do

    before do
      %w{color jazz green colour}.each{|x| @user_page_tags.add_tag x}
      @another_page = create_page
      @user_page_tags = UserPageTags.new(@user, @another_page)
      %w{green}.each{|x| @user_page_tags.add_tag x}
    end

    def page_ids_for_tag tag
      @user_page_tags.get_pages_for_tag_with_name(tag).map{|page| page.id}
    end

    it 'should get pages for a tag that was added to multiple pages' do
      assert_equal [@page.id, @another_page.id], page_ids_for_tag('green')
    end

    it 'should get one page for a tag that was added to one page' do
      assert_equal [@page.id], page_ids_for_tag('jazz')
    end

    it 'should get no pages for a tag that has been added to no pages' do
      assert_equal [], page_ids_for_tag('not-a-tag-with-a-page')
    end

  end

  describe 'duplicate tags to other page' do

    before do
      %w{color jazz}.each{|x| @user_page_tags.add_tag x}
      @another_page = create_page
    end

    it 'should duplicate' do
      @user_page_tags.duplicate_tags_to_other_page(@another_page)
      user_another_page_tags = UserPageTags.new(@user, @another_page)
      assert_equal %w{color jazz}, user_another_page_tags.get_tag_names
    end

  end

end
