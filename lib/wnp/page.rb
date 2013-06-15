module Wnp

  class Page < Struct.new(:name)

    def validate_name
      return "blank" if ! name || name.empty?
      return "too_short" if name.size < 3
      return "too_long" if name.size > 60
      if name !~ /^[a-z0-9-]+$/
        return "only_a_z_0_9_and_hyphens_ok"
      end
      nil
    end

  end

end

require "minitest/autorun"

describe Wnp::Page do

  describe "validate_name" do

    def validate_name(name)
      page = Wnp::Page.new(name)
      page.validate_name
    end

    describe "nil or blank" do

      it "when nil" do
        assert_equal validate_name(nil), "blank"
      end

      it "when blank" do
        assert_equal validate_name(""), "blank"
      end

    end

    describe "length of name" do

      it "when too short" do
        assert_equal validate_name("x"), "too_short"
      end

      it "when too long" do
        assert_equal validate_name("x" * 100), "too_long"
      end

      it "when just right" do
        assert_equal validate_name("hello-there"), nil
      end

    end

    describe "character set" do

      it "should not allow underscores" do
        assert_equal validate_name("hellothere_"), "only_a_z_0_9_and_hyphens_ok"
      end

      it "should not allow spaces" do
        assert_equal validate_name("hello there"), "only_a_z_0_9_and_hyphens_ok"
      end

      it "should allow numbers" do
        assert_equal validate_name("hello-there-89"), nil
      end

      it "should allow a-z and hyphens" do
        assert_equal validate_name("hello-there"), nil
      end

    end

  end

end
