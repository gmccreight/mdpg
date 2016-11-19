# frozen_string_literal: true
require_relative '../spec_helper'

require 'tmpdir'

describe DataStore do
  before do
    @temp_dir = Dir.mktmpdir
  end

  after do
    FileUtils.remove_entry @temp_dir
  end

  it 'sets, gets, and deletes the data' do
    @data = DataStore.new @temp_dir
    @data.set 'somekey', hello: 'what', goodbye: 'when'
    hash = @data.get 'somekey'
    assert_equal 'what', hash[:hello]
    @data.virtual_delete 'somekey'
    assert_nil @data.get('somekey')
  end

  it 'should GC least recently used data structures when has FS backing' do
    limit = 3
    $data_store = DataStore.new @temp_dir, lru_gc_size_threshold: limit
    page = Page.create name: 'yolo', text: 'foo'
    assert_equal 0, page.revision

    page.text = 'new text 1'
    page.save

    page = Page.find(1)
    assert_equal 'new text 1', page.text
    assert_equal 1, page.revision

    page.text = 'new text 2'
    page.save

    page = Page.find(1)
    assert_equal 'new text 2', page.text
    assert_equal 2, page.revision

    assert_equal limit, $data_store.data_in_memory.size
  end
end
