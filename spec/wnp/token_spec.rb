require_relative "../spec_helper"

describe Wnp::Token do

  describe "validate" do

    def validate text
      Wnp::Token.new(text).validate
    end

    describe "nil or blank" do

      it "when nil" do
        assert_equal :blank, validate(nil)
      end

      it "when blank" do
        assert_equal :blank, validate("")
      end

    end

    describe "length" do

      it "when too short" do
        assert_equal :too_short, validate("x")
      end

      it "when too long" do
        assert_equal :too_long, validate("x" * 100)
      end

      it "when just right" do
        assert_equal nil, validate("hello-there")
      end

    end

    describe "character set" do

      it "should not allow underscores" do
        assert_equal :only_a_z_0_9_and_hyphens_ok, validate("hellothere_")
      end

      it "should not allow spaces" do
        assert_equal :only_a_z_0_9_and_hyphens_ok, validate("hello there")
      end

      it "should allow numbers" do
        assert_equal nil, validate("hello-there-89")
      end

      it "should allow a-z and hyphens" do
        assert_equal nil, validate("hello-there")
      end

    end

  end

end
