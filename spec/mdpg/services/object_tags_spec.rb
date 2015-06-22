require_relative '../../spec_helper'

describe ObjectTags do
  before do
    $data_store = memory_datastore
    @object = Page.create name: 'killer', revision: 1
    @object_tags = ObjectTags.new(@object)
  end

  def page_ids_for_tag_with_name(name)
    tag = Tag.find_by_index(:name, name)
    return [] unless tag
    tag.page_ids
  end

  def sorted_tag_names
    @object_tags.sorted_tag_names
  end

  describe 'adding' do
    it 'should be able to add a object tag' do
      @object_tags.add_tag 'cool-house'
      assert @object_tags.has_tag_with_name?('cool-house')
    end

    it 'should not add a tag if the name does not validate' do
      @object_tags.add_tag 'not a valid name'
      assert_equal [], sorted_tag_names
    end

    it 'should be able to add multiple different tags' do
      @object_tags.add_tag 'cool-house'
      @object_tags.add_tag 'adam'
      assert_equal ['adam', 'cool-house'], sorted_tag_names
    end

    it 'should be not add the same tag more than once' do
      @object_tags.add_tag 'cool-house'
      @object_tags.add_tag 'cool-house'
      assert_equal ['cool-house'], sorted_tag_names
    end

    describe 'list of object ids associated with tag' do
      it 'should update for each tag' do
        @object_tags.add_tag 'cool-house'
        @object_tags.add_tag 'adam'
        assert_equal [@object.id], page_ids_for_tag_with_name('cool-house')
        assert_equal [@object.id], page_ids_for_tag_with_name('adam')
        assert_equal [], page_ids_for_tag_with_name('not-a-tag-with-a-page')
      end

      it 'should update to show multiple pages associated with same tag' do
        @object_tags.add_tag 'cool-house'
        other_page = Page.create name: 'killer-fu'
        other_page_tags = ObjectTags.new(other_page)
        other_page_tags.add_tag 'cool-house'
        assert_equal [@object.id, other_page.id],
          page_ids_for_tag_with_name('cool-house')
      end
    end
  end

  describe 'removing' do
    before do
      @object_tags.add_tag 'cool-house'
      @object_tags.add_tag 'adam'
      assert_equal ['adam', 'cool-house'], sorted_tag_names
    end

    it 'should be able to remove a tag' do
      @object_tags.remove_tag 'cool-house'
      assert_equal ['adam'], sorted_tag_names
    end

    it 'should silently fail if you try to remove a non-existent tag' do
      @object_tags.remove_tag 'does-not-exist'
      assert_equal ['adam', 'cool-house'], sorted_tag_names
    end

    describe 'list of object ids associated with tag' do
      it 'should remove the only page associated with the tag' do
        assert_equal [@object.id], page_ids_for_tag_with_name('cool-house')
        @object_tags.remove_tag 'cool-house'
        assert_equal [], page_ids_for_tag_with_name('cool-house')
      end

      it 'should remove one of the pages associated with the tag' do
        other_page = Page.create name: 'killer-fu'
        other_page_tags = ObjectTags.new(other_page)
        other_page_tags.add_tag 'cool-house'

        assert_equal [@object.id, other_page.id],
          page_ids_for_tag_with_name('cool-house')

        other_page_tags.remove_tag 'cool-house'

        assert_equal [@object.id], page_ids_for_tag_with_name('cool-house')
      end
    end
  end
end
