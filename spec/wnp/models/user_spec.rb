require_relative "../../spec_helper"

describe Wnp::Models::User do

  before do
    $data_store = get_memory_datastore()
  end

  it "should make a user with email" do
    user = Wnp::Models::User.create name:"John", email:"good@email.com"
    assert_equal 1, user.id
    assert_equal "good@email.com", user.email
  end

  it "should make a user without email" do
    user = Wnp::Models::User.create name:"John"
    assert_equal 1, user.id
    assert_equal nil, user.email
  end

  it "should increment the id" do
    u1 = Wnp::Models::User.create name:"John"
    assert_equal 1, u1.id

    u2 = Wnp::Models::User.create name:"Tim"
    assert_equal 2, u2.id
  end

end
