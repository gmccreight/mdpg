require_relative "../spec_helper"

describe Wnp::Page do

  describe "validate_name" do

    def validate_name name
      page = Wnp::Page.new(nil, 1, name)
      page.validate_name
    end

    it "when nil" do
      assert_equal :blank, validate_name(nil)
    end

    it "when too short" do
      assert_equal :too_short, validate_name("x")
    end

    it "should be ok" do
      assert_equal nil, validate_name("hello-there-89")
    end

  end

end
