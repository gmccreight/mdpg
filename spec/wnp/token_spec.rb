require "wnp/token"

require "minitest/autorun"

describe Wnp::Token do

  describe "validate" do

    def validate(text)
      Wnp::Token.new(text).validate
    end

    describe "nil or blank" do

      it "when nil" do
        assert_equal validate(nil), :blank
      end

      it "when blank" do
        assert_equal validate(""), :blank
      end

    end

    describe "length" do

      it "when too short" do
        assert_equal validate("x"), :too_short
      end

      it "when too long" do
        assert_equal validate("x" * 100), :too_long
      end

      it "when just right" do
        assert_equal validate("hello-there"), nil
      end

    end

    describe "character set" do

      it "should not allow underscores" do
        assert_equal validate("hellothere_"), :only_a_z_0_9_and_hyphens_ok
      end

      it "should not allow spaces" do
        assert_equal validate("hello there"), :only_a_z_0_9_and_hyphens_ok
      end

      it "should allow numbers" do
        assert_equal validate("hello-there-89"), nil
      end

      it "should allow a-z and hyphens" do
        assert_equal validate("hello-there"), nil
      end

    end

  end

end
