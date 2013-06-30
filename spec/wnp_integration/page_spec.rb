require_relative "../spec_helper"

describe "Integration" do

  describe "page" do

    describe "creation" do

      before do
        @user = create_user 1
        @env = Wnp::Env.new(get_data(), @user)
        @page = Wnp::Page.new(@env)
      end

      def create_page_with_name name
        Wnp::Page.create(@env, :name => name)
      end

      it "should be able to create a page and reload it" do
        create_page_with_name "hello-there"
        reloaded_page = Wnp::Page.new(@env, 1)
        reloaded_page.load
        assert_equal "hello-there", reloaded_page.name
      end

      it "should add each of the newly created page to the user's pages" do
        assert_equal [], @user.get_page_ids()
        create_page_with_name "first-page-created"
        assert_equal [1], @user.get_page_ids()
        create_page_with_name "second-page-created"
        assert_equal [1,2], @user.get_page_ids()
      end

      describe "pagedata-max-id" do

        it "should be created and incremented from 0 the first time it's used" do
          create_page_with_name "hello-there"
          assert_equal 1, get_data().get("pagedata-max-id")
        end

        it "should incremented for every new page" do
          get_data().set("pagedata-max-id", 3)
          create_page_with_name "hello-there"
          assert_equal 4, get_data().get("pagedata-max-id")
        end

        it "should not create a page with a bad name" do
          create_page_with_name "Bad Name"
          assert_equal nil, get_data().get("pagedata-max-id")
        end

      end

    end

    describe "loading and saving" do

      before do
        create_page :id => 1, :name => "orig-name", :revision => 0
      end

      def get_page_1
        user = create_user 1
        env = Wnp::Env.new(get_data(), user)
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
        assert_equal 1, page.revision
        page.name = "new-name"
        page.save

        page_reloaded = get_page_1
        assert_equal "new-name", page_reloaded.name
        assert_equal 2, page_reloaded.revision
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
