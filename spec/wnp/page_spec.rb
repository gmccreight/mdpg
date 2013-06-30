require_relative "../spec_helper"

describe Wnp::Page do

  let (:user) { Wnp::User.new }
  let (:env)  { OpenStruct.new data: get_data(), user:user}

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

  describe "creation" do

    it "increments page ids" do
      user.stub :add_page, true do
        page1 = Wnp::Page.create(env, name:"hello")
        assert_equal 1, page1.id

        page2 = Wnp::Page.create(env, name:"foo")
        assert_equal 2, page2.id
      end
    end

    describe "adds page to user" do

      # set an actual expectation for these tests
      let (:user) { MiniTest::Mock.new.expect :add_page, true, [Integer] }

      it "should add the newly created page to the associated user" do
        page = Wnp::Page.create(env, name:"hello")
        assert_equal 1, page.id
        user.verify
      end

      it "should not add the page if it has a bad name" do
        page = Wnp::Page.create(env, name:"BAD NAME")
        assert_raises MockExpectationError do
          user.verify
        end
      end

    end

  end

end
