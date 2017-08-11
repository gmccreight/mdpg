# frozen_string_literal: true
require File.expand_path '../sinatra_helper.rb', __FILE__

describe 'page_search' do
  before do
    $data_store = memory_datastore

    @user = User.create name: 'Jordan',
      email: 'jordan@example.com', password: 'cool'
    UserPages.new(@user).create_page name: 'good-page-name',
      text: 'I wish I had something *interesting* to say!'
    UserPages.new(@user).create_page name: 'cool-interesting-things',
      text: 'Fast cars'
  end

  def search_pages(query, only:)
    params = { query: query }
    if !only.nil?
      params[:only] = only
    end
    post '/page/search', params, authenticated_session(@user)
  end

  it 'should integrate the search ok' do
    search_pages 'good', only: nil
    text = last_response.body

    assert text.include? '1 pages with matching name'
    assert text.include? 'good-page-name'
    assert text.include? '0 pages with matching text'
  end

  it 'should be able to pass only' do
    search_pages 'good', only: 'names,tags,texts'
    text = last_response.body
    assert text.include? '1 pages with matching name'

    search_pages 'good', only: 'tags,texts'
    text = last_response.body
    assert text.include? '0 pages with matching name'
  end
end
