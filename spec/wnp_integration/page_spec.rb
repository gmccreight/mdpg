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

    it "should load a page from data ok" do
      page_data = {:id => 1, :name => "cool-name"}
      @data.set "page-1", page_data
      page = Wnp::Page.get(@data, 1)
      assert_equal "cool-name", page.name
    end

  end

end
