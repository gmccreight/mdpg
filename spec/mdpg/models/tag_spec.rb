# frozen_string_literal: true
require_relative '../../spec_helper'

describe Tag do
  before do
    $data_store = memory_datastore
  end

  describe 'find by name' do
    it 'should find a tag by name if exists' do
      Tag.create name: 'food'
      tag = Tag.find_by_index :name, 'food'
      assert_equal 1, tag.id
    end

    it 'should not find a tag by name if it does not exist' do
      tag = Tag.find_by_index :name, 'not-there'
      assert_equal nil, tag
    end
  end
end
