require_relative "../../spec_helper"

describe Wnp::Models::Tag do

  before do
    $data_store = get_memory_datastore()
  end

  describe "find by name" do

    it "should find a tag by name if exists" do
      Wnp::Models::Tag.create name:"food"
      tag = Wnp::Models::Tag.find_by_index :name, "food"
      assert_equal 1, tag.id
    end

    it "should not find a tag by name if it does not exist" do
      tag = Wnp::Models::Tag.find_by_index :name, "not-there"
      assert_equal nil, tag
    end

  end

end
