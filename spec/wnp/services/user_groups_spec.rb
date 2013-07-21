require_relative "../../spec_helper"

describe Wnp::Services::UserGroups do

  before do
    @user = create_user

    @zebra_group = Wnp::Models::Group.create name:"zebra-training"
    @alaska_group = Wnp::Models::Group.create name:"alaska-crab"

    @user.add_group @zebra_group
    @user.add_group @alaska_group

    @user_groups = Wnp::Services::UserGroups.new(@user)
  end

  it "should list the group ids and names sorted by name" do
    expected = [
      [@alaska_group.id, "alaska-crab"],
      [@zebra_group.id, "zebra-training"]
    ]
    assert_equal expected, @user_groups.group_ids_and_names_sorted_by_name()
  end

end
