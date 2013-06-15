require "wnp/data"
require "wnp/page"

require "tmpdir"
require "minitest/autorun"

describe "Integration" do

  before do
    @temp_dir = Dir.mktmpdir
    @data = Wnp::Data.new @temp_dir
  end

  after do
    FileUtils.remove_entry @temp_dir
  end

  describe "page" do

    before do
      page_data = {:id => 1, :name => "orig-name"}
      @data.set "page-1", page_data
    end

    it "should load a page from data ok" do
      page = Wnp::Page.get(@data, 1)
      assert_equal "orig-name", page.name
    end

    it "should be able to update with an acceptable name" do
      page = Wnp::Page.get(@data, 1)
      assert_equal "orig-name", page.name
      page.name = "new-name"
      page.save

      page_reloaded = Wnp::Page.get(@data, 1)
      assert_equal "new-name", page_reloaded.name
    end

    it "should not update with an invalid name" do
      page = Wnp::Page.get(@data, 1)
      assert_equal "orig-name", page.name
      page.name = "Bad New Name"
      assert_equal false, page.save

      page_reloaded = Wnp::Page.get(@data, 1)
      assert_equal "orig-name", page_reloaded.name
    end

  end

end
