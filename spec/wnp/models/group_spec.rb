require_relative "../../spec_helper"

describe Wnp::Models::Group do

  before do
    $data_store = get_memory_datastore()
  end

  def create_group_with_name name
    Page.create name:name
  end

  describe "creation" do

    it "should make a group" do
      group = create_group_with_name "good"
      assert_equal group.name, "good"
    end

  end

end
