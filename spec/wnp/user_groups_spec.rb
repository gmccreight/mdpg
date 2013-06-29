require_relative "../spec_helper"

describe Wnp::UserGroups do

  before do
    @user = Wnp::User.new(get_data(), 1)
    @env = Wnp::Env.new(get_data(), @user)
    @user_groups = Wnp::UserGroups.new(@env, @user)

    user = create_user 1

    create_group 1, :name => "zebra-training"
    create_group 2, :name => "alaska-crab"

    user.add_group 1
    user.add_group 2
  end

  it "should list the group ids and names sorted by name" do
    assert_equal [[2, "alaska-crab"], [1, "zebra-training"]], @user_groups.group_ids_and_names_sorted_by_name()
  end

end
