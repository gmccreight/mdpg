require_relative "./spec_helper"

require "search_query_parser"

describe SearchQueryParser do


  before do
    @parser = SearchQueryParser.new()
  end

  describe "search string" do

    it "should return a simple search string unchanged" do
      @parser.query = "notes"
      assert_equal "notes", @parser.search_string()
    end

    it "should return the search string with the tags removed" do
      @parser.query = "kittens tags:grown-man,old"
      assert_equal "kittens", @parser.search_string()
    end

  end

  describe "tags" do

    it "should return the tags" do
      @parser.query = "kittens tags:grown-man,old"
      assert_equal %w{grown-man old}, @parser.tags()
    end

    it "should return an empty array if no tags" do
      @parser.query = "kittens"
      assert_equal [], @parser.tags()
    end

  end

end
