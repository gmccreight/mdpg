require "wnp/user"
require "wnp/user_vm"

require "minitest/autorun"

describe Wnp::UserVm do

  before do
    @data = Wnp::Data.new :memory
    @user = Wnp::User.new(@data, 1)
    @env = Wnp::Env.new(@data, @user)
    @user_vm = Wnp::UserVm.new(@env, @user)
  end

  it "should list the page ids and names sorted by name" do
    @data.set "userdata-1-page-ids", [1,2]
    @data.set "pagedata-1-0", {:name => "zebra-training"}
    @data.set "pagedata-2-0", {:name => "alaska-crab"}
    assert_equal [[2, "alaska-crab"], [1, "zebra-training"]], @user_vm.page_ids_and_names_sorted_by_name()
  end

end
