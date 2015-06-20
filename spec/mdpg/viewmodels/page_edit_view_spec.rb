require_relative '../../spec_helper'

describe PageEditView do

  before do
    $data_store = get_memory_datastore
    @user = create_user
  end

  describe 'text you see in edit box' do

    it 'should be what is in the text' do
      page = Page.create name:'my-bongos',
        text:'This is *bongos*, indeed.'
      vm = PageEditView.new(@user, page)
      expected = 'This is *bongos*, indeed.'
      assert_equal expected, vm.get_text
    end

    it 'should translate partial includes to other pages into easy-edit' do
      user_pages = UserPages.new @user

      ident = 'abababababababab'

      other_text = (<<-EOF).gsub(/^ +/, '')
        something that we're talking about
        with [[#important-idea:#{ident}]]
        John James said: "this is an important idea"
        [[#important-idea:#{ident}]]
      EOF
      other_page = user_pages.create_page name:'other-page', text:other_text

      this_text = (<<-EOF).gsub(/^ +/, '')
        From the other page:

        [[other-page#important-idea]]

        is what it was talking about
      EOF

      this_page = user_pages.create_page name:'this-page', text:this_text

      expected_internal_text = (<<-EOF).gsub(/^ +/, '')
        From the other page:

        [[mdpgpage:#{other_page.id}:#{ident}]]

        is what it was talking about
      EOF

      assert_equal expected_internal_text, this_page.text

      expected_editing_text = (<<-EOF).gsub(/^ +/, '')
        From the other page:

        [[other-page#important-idea]]

        is what it was talking about
      EOF

      vm = PageEditView.new(@user, this_page)
      assert_equal expected_editing_text, vm.get_text

    end

  end

end
