# frozen_string_literal: true
require_relative '../../spec_helper'

describe UserPages do
  before do
    $data_store = memory_datastore
    @user = create_user

    @zebra_page = Page.create name: 'zebra-training',
      text: 'the text for page 1'
    @alaska_page = Page.create name: 'alaska-crab',
      text: 'the text for page 2'

    @user.add_page @zebra_page
    @user.add_page @alaska_page

    @user_pages = UserPages.new(@user)
  end

  describe 'adds page to user' do
    before do
      @user_pages = UserPages.new(@user)
    end

    it 'should add the newly created page to the user' do
      initial_num_pages = @user.page_ids.size
      @user_pages.create_page name: 'hello'
      assert_equal initial_num_pages + 1, @user.page_ids.size
    end

    it 'should not add the page if it has a bad name' do
      initial_num_pages = @user.page_ids.size
      @user_pages.create_page name: 'Bad Name'
      assert_equal initial_num_pages, @user.page_ids.size
    end

    it 'should not add the page if it already exists' do
      @user_pages.create_page name: 'hello'
      assert_raises PageAlreadyExistsException do
        @user_pages.create_page name: 'hello'
      end
    end

    it 'should provide a default 32 character hexcode if name is empty' do
      page = @user_pages.create_page name: ''
      assert page.name.size == 32
    end
  end

  describe 'delete page' do
    before do
      @user = User.create name: 'Jordan'
      @user_pages = UserPages.new(@user)

      @page = @user_pages.create_page name: 'hello'

      @user_page_tags = UserPageTags.new(@user, @page)
      @user_page_tags.add_tag 'cool-house'

      @page_id = @page.id
      assert_equal 'hello', Page.find(@page_id).name
    end

    it 'should delete the page' do
      assert Page.find(@page_id)
      @user_pages.delete_page @page.name
      assert_nil Page.find(@page_id)
    end

    it 'should delete the association with the user' do
      assert @user_pages.find_page_with_name('hello')
      @user_pages.delete_page @page.name
      assert_nil @user_pages.find_page_with_name('hello')
    end

    it 'should remove tag from user if was only on this one page' do
      assert_equal ['cool-house'], @user_page_tags.tag_names
      @user_pages.delete_page @page.name
      assert_equal [], @user_page_tags.tag_names
    end
  end

  describe 'page with name' do
    it 'should return a page with a matching name' do
      assert_equal 'alaska-crab',
        @user_pages.find_page_with_name('alaska-crab').name
    end

    it 'should not return a page if the user does not have that page' do
      assert_nil @user_pages.find_page_with_name('non-existent')
    end
  end

  describe 'pages_with_text_containing_text' do
    it 'should give a single result if only one page matches' do
      assert_equal ['alaska-crab'],
        @user_pages.pages_with_text_containing_text('page 2').map(&:name)
    end

    it 'should give multiple results if multiple pages match' do
      assert_equal ['zebra-training', 'alaska-crab'],
        @user_pages.pages_with_text_containing_text('the text').map(&:name)
    end

    it 'should match in a case-insensitive way' do
      assert_equal ['alaska-crab'],
        @user_pages.pages_with_text_containing_text('Page 2').map(&:name)
    end
  end

  describe 'pages_with_names_containing_text' do
    it 'should give a single result if only one page matches' do
      assert_equal ['alaska-crab'],
        @user_pages.pages_with_names_containing_text('lask').map(&:name)
    end

    it 'should give multiple results if multiple pages match' do
      assert_equal ['zebra-training', 'alaska-crab'],
        @user_pages.pages_with_names_containing_text('a').map(&:name)
    end

    it 'should match in a case-insensitive way' do
      assert_equal ['alaska-crab'],
        @user_pages.pages_with_names_containing_text('Alaska').map(&:name)
    end
  end

  describe 'duplicating a page' do
    before do
      @user = User.create name: 'Jordan'
      @user_pages = UserPages.new(@user)

      @page = @user_pages.create_page name: 'hello'
      @page.text = 'world'
      @page.save

      @user_page_tags = UserPageTags.new @user, @page
      @user_page_tags.add_tag 'cool-house'

      @page_id = @page.id
      assert_equal 'hello', Page.find(@page_id).name
    end

    it 'should duplicate a page, including the text and tags' do
      new_page = @user_pages.duplicate_page 'hello', Date.today
      assert_equal 'hello-2', new_page.name
      assert_equal 'world', new_page.text

      user_page_tags = UserPageTags.new @user, new_page
      assert_equal ['cool-house'], user_page_tags
        .tags_for_page(new_page).map(&:name)
    end

    it "should only duplicate the page's tags, not all page tags" do
      different_page = @user_pages.create_page name: 'different-page'
      user_a_different_page_tags = UserPageTags.new(@user, different_page)
      user_a_different_page_tags.add_tag 'tag-on-different-page'

      new_page = @user_pages.duplicate_page 'hello', Date.today

      user_page_tags = UserPageTags.new @user, new_page
      assert_equal ['cool-house'], user_page_tags
        .tags_for_page(new_page).map(&:name)
    end

    it 'should change the date in the page title to current date' do
      @user_pages.create_page name: 'hello-2016-07-12'
      new_page = @user_pages.duplicate_page 'hello-2016-07-12', Date.parse('2017-01-01')
      assert_equal 'hello-2017-01-01', new_page.name
    end

    it 'should fail if the proposed page already exist' do
      @user_pages.create_page name: 'hello-2016-07-12'
      @user_pages.create_page name: 'hello-2017-01-01'
      assert_raises DuplicatorDatePageAlreadyExists do
        @user_pages.duplicate_page 'hello-2016-07-12', Date.parse('2017-01-01')
      end
    end

    it 'should increment if page name taken' do
      @user_pages.create_page name: 'hello-2'
      new_page = @user_pages.duplicate_page 'hello', Date.today
      assert_equal 'hello-3', new_page.name
    end

    it 'should increment if page name taken - multiple times' do
      @user_pages.create_page name: 'hello-2'
      @user_pages.create_page name: 'hello-3'
      new_page = @user_pages.duplicate_page 'hello', Date.today
      assert_equal 'hello-4', new_page.name
    end

    describe 'where there are a bunch of tags' do
      before do
        (2..10).to_a.each do |num|
          @user_page_tags.add_tag "tag#{num}"
        end
      end

      it 'should duplicate the page very quickly' do
        time_before = Time.now
        new_page = @user_pages.duplicate_page 'hello', Date.today
        assert @user_page_tags.tags_for_page(new_page).size == 10
        assert_in_delta time_before, Time.now, 0.1
      end
    end

    describe 'where the name already ends in a -1 or -v1' do
      def page_should_duplicate_to(before_name, after_name)
        @user_pages.rename_page(@page, before_name)
        new_page = @user_pages.duplicate_page before_name, Date.today
        assert_equal after_name, new_page.name
      end

      describe 'without a v' do
        it 'should simply increment the -1 to -2' do
          page_should_duplicate_to 'test-1', 'test-2'
        end

        it 'should simply increment the -2 to -3' do
          page_should_duplicate_to 'test-2', 'test-3'
        end

        it 'should simply increment the -3 to -4' do
          page_should_duplicate_to 'test-3', 'test-4'
        end

        it 'should work with big numbers, too' do
          page_should_duplicate_to 'test-1001', 'test-1002'
        end

        it 'should increment past a pre-existing page' do
          @user_pages.create_page name: 'test-5'
          page_should_duplicate_to 'test-4', 'test-6'
        end
      end

      describe 'with a v' do
        it 'should simply increment the -v1 to -v2' do
          page_should_duplicate_to 'test-v1', 'test-v2'
        end

        it 'should simply increment the -v2 to -v3' do
          page_should_duplicate_to 'test-v2', 'test-v3'
        end

        it 'should simply increment the -v3 to -v4' do
          page_should_duplicate_to 'test-v3', 'test-v4'
        end

        it 'should work with big numbers, too' do
          page_should_duplicate_to 'test-v1001', 'test-v1002'
        end

        it 'should increment past a pre-existing page' do
          @user_pages.create_page name: 'test-v5'
          page_should_duplicate_to 'test-v4', 'test-v6'
        end
      end
    end
  end
end
