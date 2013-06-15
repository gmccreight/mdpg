require "wnp/page"

require "minitest/autorun"

describe Wnp::Page do

  describe "validate_name" do

    def validate_name(name)
      page = Wnp::Page.new(name)
      page.validate_name
    end

    it "when nil" do
      assert_equal validate_name(nil), :blank
    end

    it "when too short" do
      assert_equal validate_name("x"), :too_short
    end

    it "should be ok" do
      assert_equal validate_name("hello-there-89"), nil
    end

  end

end
