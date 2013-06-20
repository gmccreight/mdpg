require_relative "../spec_helper"

require "wnp/user_vm"

require "minitest/autorun"

describe Wnp::UserVm do

  before do
    @data = get_data()
    @user = Wnp::User.new(@data, 1)
    @env = Wnp::Env.new(@data, @user)
    @user_vm = Wnp::UserVm.new(@env, @user)
  end

  it "should list the page ids and names sorted by name" do
    @data.set "userdata-1-page-ids", [1,2]

    create_page 1, :name => "zebra-training"
    create_page 2, :name => "alaska-crab"

    assert_equal [[2, "alaska-crab"], [1, "zebra-training"]], @user_vm.page_ids_and_names_sorted_by_name()
  end

end
