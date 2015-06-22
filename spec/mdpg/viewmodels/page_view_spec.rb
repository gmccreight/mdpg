require_relative '../../spec_helper'

describe PageView do
  before do
    $data_store = memory_datastore
    @user = create_user
    @page = Page.create name: 'my-bongos',
      text: 'This is *bongos*, indeed.'
    @page_1_vm = PageView.new(@user, @page, nil)
  end

  def user_1_page_tags
    UserPageTags.new(@user, @page)
  end

  def page_1_tags
    ObjectTags.new(@page)
  end

  describe 'which things to show' do
    describe 'edit button' do
      it 'should show the edit button when no sharing token' do
        vm = PageView.new(@user, @page, nil)
        assert vm.should_show_edit_button?
      end

      it 'should show the edit button when readwrite sharing token' do
        vm = PageView.new(@user, @page, :readwrite)
        assert vm.should_show_edit_button?
      end

      it 'should not show the edit button when readonly sharing token' do
        vm = PageView.new(@user, @page, :readonly)
        refute vm.should_show_edit_button?
      end
    end
  end

  describe 'rendered html for page' do
    describe 'which transcludes labeled sections from other pages' do
      it 'should work' do
        ident = 'abababababababab'

        other_text = (<<-EOF).gsub(/^[ ]{10}/, '')
          something that we're talking about
          with [[#important-idea:#{ident}]]

          * check this
              * indented

          John James said: "this is an important command:"

              ls -l

          [[#important-idea:#{ident}]]
        EOF
        other_page = Page.create name: 'other-page', text: other_text

        this_text = (<<-EOF).gsub(/^ +/, '')
          From the other page:

          [[mdpgpage:#{other_page.id}:#{ident}]]

          is what it was talking about
        EOF

        this_page = Page.create name: 'this-page', text: this_text

        page_vm = PageView.new(@user, this_page, nil)

        expected_text = (<<-EOF).gsub(/^[ ]{10}/, '')
          From the other page:


          <div class='transcluded-section-header top-header'>
            <a href='/p/other-page'>other-page</a>#important-idea
          </div>

          * check this
              * indented

          John James said: "this is an important command:"

              ls -l

          <div class='transcluded-section-header bottom-header'>&nbsp;</div>


          is what it was talking about
        EOF

        assert_equal expected_text, page_vm.text_before_markdown_parsing
      end
    end

    it "should render the page's markdown as html" do
      assert_equal "<p>This is <em>bongos</em>, indeed.</p>\n",
        @page_1_vm.fully_rendered_text
    end
  end

  describe 'new tag for page' do
    it 'should add a new tag to both page and user' do
      @page_1_vm.add_tag('good-stuff')
      assert page_1_tags.has_tag_with_name?('good-stuff')
      assert user_1_page_tags.has_tag_with_name?('good-stuff')
      assert_equal 1, user_1_page_tags.tag_count('good-stuff')
    end

    it 'should be able to remove an existing tag' do
      @page_1_vm.add_tag('good-stuff')
      @page_1_vm.remove_tag('good-stuff')
      refute page_1_tags.has_tag_with_name?('good-stuff')
      refute user_1_page_tags.has_tag_with_name?('good-stuff')
      assert_equal 0, user_1_page_tags.tag_count('good-stuff')
    end
  end

  describe 'multiple pages with same tag' do
    before do
      page_2 = Page.create name: 'food', text: 'foo'
      @page_2_vm = PageView.new(@user, page_2)

      @page_1_vm.add_tag('good-stuff')
      @page_2_vm.add_tag('good-stuff')
    end

    it "should increment the user's tags count to 2" do
      assert_equal 2, user_1_page_tags.tag_count('good-stuff')
    end
  end

  describe 'same tag as before' do
    it 'should not add the same tag again' do
      @page_1_vm.add_tag('good-stuff')
      assert page_1_tags.has_tag_with_name?('good-stuff')
      assert user_1_page_tags.has_tag_with_name?('good-stuff')
      assert_equal 1, user_1_page_tags.tag_count('good-stuff')

      @page_1_vm.add_tag('good-stuff')
      assert user_1_page_tags.has_tag_with_name?('good-stuff')
      assert_equal 1, user_1_page_tags.tag_count('good-stuff')
    end
  end

  describe 'suggested tags' do
    before do
      page_2 = Page.create name: 'food', text: 'foo'
      @page_2_vm = PageView.new(@user, page_2)

      %w(colour great green gross).each do |tag|
        @page_1_vm.add_tag tag
      end

      %w(green greed).each do |tag|
        @page_2_vm.add_tag tag
      end
    end

    it 'should find a similar tag from other pages but not this one' do
      assert_equal ['greed'], @page_1_vm.tag_suggestions_for('greet')
    end
  end
end
