require_relative "../../spec_helper"

describe Page do

  before do
    $data_store = get_memory_datastore()
  end

  def create_page_with_name name
    Page.create name:name, text:"foo"
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

      page = Page.find(1)
      assert_equal "new text 1", page.text
      assert_equal 1, page.revision

      page.text = "new text 2"
      page.save

      page = Page.find(1)
      assert_equal "new text 2", page.text
      assert_equal 2, page.revision
    end

  end

  describe "deletion" do

    it "should delete a page" do
      create_page_with_name "good"
      page = Page.find(1)
      assert_equal 1, page.id

      page.virtual_delete()
      assert_nil Page.find(1)
    end

  end

  describe "finding by various sharing tokens" do

    it "should find by readonly_sharing_token" do
      create_page_with_name "not-the-page"
      page = create_page_with_name "the-page"
      assert_equal page.readonly_sharing_token.size, 32
      found_page = Page.find_by_index(:readonly_sharing_token,
                                      page.readonly_sharing_token)
      assert_equal page.id, found_page.id
    end

    it "should find by readwrite_sharing_token" do
      page = create_page_with_name "the-page"
      assert_equal page.readwrite_sharing_token.size, 32
      found_page = Page.find_by_index(:readwrite_sharing_token,
                                      page.readwrite_sharing_token)
      assert_equal page.id, found_page.id
    end

  end

end
