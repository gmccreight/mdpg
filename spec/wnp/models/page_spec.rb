require_relative "../../spec_helper"

describe Wnp::Models::Page do

  before do
    $data_store = get_memory_datastore()
  end

  def create_page_with_name name
    Wnp::Models::Page.create name:name, text:"foo"
  end

  describe "creation" do

    it "should make a page" do
      page = create_page_with_name "good"
      assert_equal page.name, "good"
    end

  end

  describe "updating" do

    it "should update the revision number" do
      page = create_page_with_name "good"
      assert_equal 0, page.revision

      page.text = "new text 1"
      page.save

      page = Wnp::Models::Page.find(1)
      assert_equal "new text 1", page.text
      assert_equal 1, page.revision

      page.text = "new text 2"
      page.save

      page = Wnp::Models::Page.find(1)
      assert_equal "new text 2", page.text
      assert_equal 2, page.revision
    end

  end

end
