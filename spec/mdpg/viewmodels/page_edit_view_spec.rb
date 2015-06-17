require_relative "../../spec_helper"

describe PageEditView do

  before do
    $data_store = get_memory_datastore()
    @user = create_user
    @page = Page.create name:"my-bongos",
      text:"This is *bongos*, indeed."
    @page_1_edit_vm = PageEditView.new(@user, @page)
  end

  describe "text you see in edit box" do

    it "should be what is in the text" do
      expected = "This is *bongos*, indeed."
      assert_equal expected, @page_1_edit_vm.get_text
    end

  end

end
