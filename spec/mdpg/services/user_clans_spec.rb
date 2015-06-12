require_relative "../../spec_helper"

describe UserClans do

  before do
    $data_store = get_memory_datastore()
    @user = create_user

    @zebra_clan = Clan.create name:"zebra-training"
    @alaska_clan = Clan.create name:"alaska-crab"

    @user.add_clan @zebra_clan
    @user.add_clan @alaska_clan

    @user_clans = UserClans.new(@user)
  end

  it "should list the clan ids and names sorted by name" do
    expected = [
      [@alaska_clan.id, "alaska-crab"],
      [@zebra_clan.id, "zebra-training"]
    ]
    assert_equal expected, @user_clans.clan_ids_and_names_sorted_by_name()
  end

end
