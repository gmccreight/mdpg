require_relative "../spec_helper"

require 'tmpdir'

describe DataStore do

  describe "get and set" do

    before do
      @temp_dir = Dir.mktmpdir
      @data = DataStore.new @temp_dir
    end

    after do
      FileUtils.remove_entry @temp_dir
    end

    it "sets the data" do
      @data.set "somekey", {:hello => "what", :goodbye => "when"}
      hash = @data.get "somekey"
      assert_equal "what", hash[:hello]
    end

  end

end
