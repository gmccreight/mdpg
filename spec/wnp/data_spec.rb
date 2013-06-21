require_relative "../spec_helper"

require 'wnp/data'

require 'tmpdir'

require "minitest/autorun"

describe Wnp::Data do

  describe "get and set" do

    before do
      @temp_dir = Dir.mktmpdir
      @data = Wnp::Data.new @temp_dir
    end

    after do
      FileUtils.remove_entry @temp_dir
    end

    it "sets the data" do
      @data.set "somekey", {:hello => "what", :goodbye => "when"}
      hash = @data.get "somekey"
      assert_equal "what", hash[:hello]
    end

    it "should be able to persist and retrieve a large array of data quickly" do
      array_length = 10000
      @data.set "somekey", (1..array_length).to_a
      array2 = @data.get "somekey"
      assert_equal array_length, array2.length
    end

    it "should be able to persist and retrieve a large hash of data quickly" do
      hash_length = 10000
      hash = {}
      (1..hash_length).to_a.each do |key|
        hash[key.to_s.to_sym] = "hello"
      end
      @data.set "somekey", hash
      hash2 = @data.get "somekey"
      assert_equal hash_length, hash2.length
      assert_equal "hello", hash2["3".to_sym]
    end

  end

end
