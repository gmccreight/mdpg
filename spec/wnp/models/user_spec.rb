require_relative "../../spec_helper"

describe Wnp::Models::User do

  before do
    $data_store = get_memory_datastore()
  end

  describe "creation" do

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

  describe "finding" do

    before do
      Wnp::Models::User.create name:"John"
      Wnp::Models::User.create name:"Tim"
    end

    it "should find first user" do
      assert_equal "John", Wnp::Models::User.find(1).name
    end

    it "should find second user" do
      assert_equal "Tim", Wnp::Models::User.find(2).name
    end

    it "should not find a non-existant user" do
      assert_equal nil, Wnp::Models::User.find(3)
    end

  end

  describe "updating" do

    it "should update a user" do
      Wnp::Models::User.create name:"John"
      user = Wnp::Models::User.find(1)
      assert_equal "John", user.name
      user.name = "Frits"
      user.save

      reloaded_user = Wnp::Models::User.find(1)
      assert_equal reloaded_user.name, "Frits"
    end

  end

end
