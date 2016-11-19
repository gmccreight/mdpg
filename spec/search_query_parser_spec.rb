# frozen_string_literal: true
require_relative './spec_helper'

require 'search_query_parser'

describe SearchQueryParser do
  before do
    @parser = SearchQueryParser.new
  end

  describe 'search string' do
    it 'should return a simple search string unchanged' do
      @parser.query = 'notes'
      assert_equal ['notes'], @parser.search_strings
    end

    it 'should return the search string with the tags removed' do
      @parser.query = 'kittens tags:grown-man,old'
      assert_equal ['kittens'], @parser.search_strings
    end

    it 'should return multiple words in a single search string by default' do
      @parser.query = 'i love cats'
      assert_equal ['i love cats'], @parser.search_strings
    end

    it 'should have many required tokens if starts with a +' do
      @parser.query = '+ i love cats'
      assert_equal %w(i love cats), @parser.search_strings
    end
  end

  describe 'tags' do
    it 'should work with a singular tag' do
      @parser.query = 'kittens tags:pepper'
      assert_equal %w(pepper), @parser.tags
    end

    it 'should work with multiple tags' do
      @parser.query = 'kittens tags:grown-man,old'
      assert_equal %w(grown-man old), @parser.tags
    end

    it 'should return an empty array if no tags' do
      @parser.query = 'kittens'
      assert_equal [], @parser.tags
    end
  end
end
