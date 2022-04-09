# frozen_string_literal: true
require_relative '../../spec_helper'

def setup_empty_user_pages
  $data_store = memory_datastore
end

def transform_it(raw)
  AdapterObsidianExporter.new.transform(raw)
end

describe AdapterObsidianExporter do
  describe 'labeled section transclusion syntax' do
    it 'should do the right thing' do
      t = 'foo [[video-bullet-proof-nest-egg#breakdown-of-allocations-by-ray-dalio:short]] bar'
      expected = 'foo ![[video-bullet-proof-nest-egg^breakdown-of-allocations-by-ray-dalio]] bar'
      assert_equal expected, transform_it(t)
    end
    it "should remove obsidian" do
      t = '[[#foo-bar:dudcwcrnzgodqmaupfzgbzmyzuqkvndg]]the deal[[#foo-bar:dudcwcrnzgodqmaupfzgbzmyzuqkvndg]]'
      expected = 'the deal ^foo-bar'
      assert_equal expected, transform_it(t)
    end
  end

end
