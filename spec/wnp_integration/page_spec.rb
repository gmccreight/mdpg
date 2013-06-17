require "wnp/env"
require "wnp/data"
require "wnp/user"
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

    describe "creation" do

      before do
        @user = Wnp::User.new(@data, 1)
        @env = Wnp::Env.new(@data, @user)
        @page = Wnp::Page.new(@env)
      end

      it "should be able to create a page and reload it" do
        @page.create("hello-there")
        reloaded_page = Wnp::Page.new(@env, 1)
        reloaded_page.load
        assert_equal "hello-there", reloaded_page.name
      end

      it "should add each of the newly created page to the user's pages" do
        assert_equal [], @user.get_page_ids()
        @page.create("first-page-created")
        assert_equal [1], @user.get_page_ids()
        @page.create("second-page-created")
        assert_equal [1,2], @user.get_page_ids()
      end

      describe "pages-max-page-id" do

        it "should be created and incremented from 0 the first time it's used" do
          @page.create("hello-there")
          assert_equal 1, @data.get("pages-max-page-id")
        end

        it "should incremented for every new page" do
          @data.set("pages-max-page-id", 3)
          @page.create("hello-there")
          assert_equal 4, @data.get("pages-max-page-id")
        end

        it "should not create a page with a bad name" do
          @page.create("Bad Name")
          assert_equal nil, @data.get("pages-max-page-id")
        end

      end

    end

    describe "loading and saving" do

      before do
        page_data = {:id => 1, :name => "orig-name", :revision => 0}
        @data.set "page-1-0", page_data
      end

      def get_page_1
        user = Wnp::User.new(@data, 1)
        env = Wnp::Env.new(@data, user)
        page = Wnp::Page.new(env, 1)
        page.load
        page
      end

      it "should load a page from data ok" do
        page = get_page_1
        assert_equal "orig-name", page.name
      end

      it "should be able to update with an acceptable name" do
        page = get_page_1
        assert_equal "orig-name", page.name
        assert_equal 0, page.revision
        page.name = "new-name"
        page.save

        page_reloaded = get_page_1
        assert_equal "new-name", page_reloaded.name
        assert_equal 1, page_reloaded.revision
      end

      it "should not update with an invalid name" do
        page = get_page_1
        assert_equal "orig-name", page.name
        page.name = "Bad New Name"
        assert_equal false, page.save

        page_reloaded = get_page_1
        assert_equal "orig-name", page_reloaded.name
      end

    end

  end

end
