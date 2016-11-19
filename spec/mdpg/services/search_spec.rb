# frozen_string_literal: true
require_relative '../../spec_helper'

describe Search do
  before do
    $data_store = memory_datastore
    @user = create_user
    @page_1 = UserPages.new(@user).create_page name: 'good-page-name',
      text: 'I wish I had something *interesting* to say!'

    @page_2 = UserPages.new(@user).create_page name: 'cool', text: 'Fast cars'
    @searcher = Search.new(@user)
  end

  def search_gets(query, names, texts, tags)
    results = @searcher.search query
    assert_equal names, results[:names].size
    assert_equal texts, results[:texts].size
    assert_equal tags, results[:tags].size
  end

  it 'should find name' do
    search_gets 'good', 1, 0, 0
  end

  it 'should find text' do
    search_gets 'car', 0, 1, 0
  end

  describe 'force multiple tokens' do
    describe 'names' do
      it 'should return a page if all the tokens match' do
        search_gets '+ good name', 1, 0, 0
      end

      it 'should not return a page if one of the tokens does not match' do
        search_gets '+ good nothing', 0, 0, 0
      end
    end

    describe 'texts' do
      it 'should return a page if all the tokens match' do
        search_gets '+ wish something', 0, 1, 0
      end

      it 'should not return a page if one of the tokens does not match' do
        search_gets '+ wish nothing', 0, 0, 0
      end
    end
  end

  describe 'case insensitivity' do
    it 'should ignore case and find lower case version of query' do
      search_gets 'Car', 0, 1, 0
    end

    it 'should ignore case and find upper case page text' do
      search_gets 'fast', 0, 1, 0
    end
  end

  describe 'tags' do
    before do
      UserPageTags.new(@user, @page_1).add_tag 'wishing'
      UserPageTags.new(@user, @page_1).add_tag 'blog-ideas'
      UserPageTags.new(@user, @page_2).add_tag 'vehicular'
      UserPageTags.new(@user, @page_2).add_tag 'blog-ideas'
    end

    describe 'searching for tag name' do
      it 'should find single exact match' do
        search_gets 'vehicular', 0, 0, 1
      end

      it 'should find single similar match' do
        search_gets 'vehicles', 0, 0, 1
      end

      it 'should return only one tag even if multiple found' do
        search_gets 'blog-ideas', 0, 0, 1
      end
    end

    describe 'search with tags limiter' do
      describe 'names' do
        it 'should find name if name matches and tag limiter matches' do
          search_gets 'good tags:wishing', 1, 0, 0
        end

        it 'should find name if name matches and tag limiter matches' do
          search_gets 'good tags:blog-ideas', 1, 0, 0
        end

        it 'should not find name if name matches but tags do not' do
          search_gets 'good tags:nope', 0, 0, 0
        end
      end

      describe 'texts' do
        it 'should find text if text matches and tag limiter matches' do
          search_gets 'cars tags:vehicular', 0, 1, 0
        end

        it 'should find text if text matches and tag limiter matches' do
          search_gets 'cars tags:cat,vehicular,dog', 0, 1, 0
        end

        it 'should not find text if text matches but tags do not' do
          search_gets 'cars tags:nope', 0, 0, 0
        end
      end
    end
  end
end
