require_relative "../spec_helper"

describe "Integration" do

  describe "group" do

    describe "creation" do

      before do
        @user = create_user 1
        @env = Wnp::Env.new(get_memory_datastore(), @user)
        @group = Wnp::Group.new(@env)
      end

      it "should be able to create a group and reload it" do
        @group.create("hello-there")
        reloaded_group = Wnp::Group.new(@env, 1)
        reloaded_group.load
        assert_equal "hello-there", reloaded_group.name
      end

      it "should add each of the newly created group to the user's groups" do
        assert_equal [], @user.get_group_ids()
        @group.create("first-group-created")
        assert_equal [1], @user.get_group_ids()
        @group.create("second-group-created")
        assert_equal [1,2], @user.get_group_ids()
      end

      describe "groupdata-max-id" do

        it "should be created and incremented from 0 the first time it's used" do
          @group.create("hello-there")
          assert_equal 1, get_memory_datastore().get("groupdata-max-id")
        end

        it "should incremented for every new group" do
          get_memory_datastore().set("groupdata-max-id", 3)
          @group.create("hello-there")
          assert_equal 4, get_memory_datastore().get("groupdata-max-id")
        end

        it "should not create a group with a bad name" do
          @group.create("Bad Name")
          assert_equal nil, get_memory_datastore().get("groupdata-max-id")
        end

      end

    end

    describe "loading and saving" do

      before do
        create_group 1, {:id => 1, :name => "orig-name", :admins => [1]}
      end

      def get_group_1
        user = create_user 1
        env = Wnp::Env.new(get_memory_datastore(), user)
        group = Wnp::Group.new(env, 1)
        group.load
        group
      end

      it "should load a group from data ok" do
        group = get_group_1
        assert_equal "orig-name", group.name
      end

      it "should be able to update with an acceptable name" do
        group = get_group_1
        assert_equal "orig-name", group.name
        group.name = "new-name"
        group.save

        group_reloaded = get_group_1
        assert_equal "new-name", group_reloaded.name
      end

      it "should not update with an invalid name" do
        group = get_group_1
        assert_equal "orig-name", group.name
        group.name = "Bad New Name"
        assert_equal false, group.save

        group_reloaded = get_group_1
        assert_equal "orig-name", group_reloaded.name
      end

    end

  end

end
