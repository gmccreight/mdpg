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

  it "should list the page names" do
    @data.set "user-1-page-ids", [1,2]
    @data.set "page-1-0", {:name => "zebra-training"}
    @data.set "page-2-0", {:name => "alaska-crab"}
    assert_equal ["alaska-crab", "zebra-training"], @user_vm.page_names()
  end

end
