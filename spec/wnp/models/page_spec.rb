require_relative "../../spec_helper"

describe Wnp::Models::Page do

  before do
    $data_store = get_memory_datastore()
  end

  def create_page_with_name name
    Wnp::Models::Page.create name:name, text:"foo"
  end

  describe "creation" do

    it "should make a user with email" do
      page = create_page_with_name "good"
      assert_equal page.name, "good"
    end

  end

end
