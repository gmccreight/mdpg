require_relative "../spec_helper"

describe Wnp::User do

  it "should make a user" do
    user = Wnp::User.new(nil, 1)
    assert_equal 1, user.id
  end

end
