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

    it "should strip the ! off the end of a query that forces full results" do
      @parser.query = "notes!"
      assert_equal "notes", @parser.search_string()
    end

    it "should return the search string with the tags removed" do
      @parser.query = "kittens tags:grown-man,old"
      assert_equal "kittens", @parser.search_string()
    end

  end

  describe "tags" do

    it "should work with a singular tag" do
      @parser.query = "kittens tags:pepper"
      assert_equal %w{pepper}, @parser.tags()
    end

    it "should work with multiple tags" do
      @parser.query = "kittens tags:grown-man,old"
      assert_equal %w{grown-man old}, @parser.tags()
    end

    it "should return an empty array if no tags" do
      @parser.query = "kittens"
      assert_equal [], @parser.tags()
    end

  end

  describe "force full search" do

    it "should force a full search if the query ends with !" do
      @parser.query = "notes!"
      assert @parser.should_force_full_search?()
    end

    it "should not force a full search if no ! at the end" do
      @parser.query = "notes"
      refute @parser.should_force_full_search?()
    end

  end

  describe "open single result in edit mode" do

    it "should open a single result in edit mode if search ends in space e" do
      @parser.query = "notes e"
      assert @parser.should_open_in_edit_mode?()
      assert_equal "notes", @parser.search_string()
    end

    it "should not open a normal search in edit mode" do
      @parser.query = "notes"
      refute @parser.should_open_in_edit_mode?()
    end

  end

end
