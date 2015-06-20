require File.expand_path '../sinatra_helper.rb', __FILE__

describe 'page_search' do

  before do
    $data_store = get_memory_datastore()

    @user = User.create name: 'Jordan',
      email: 'jordan@example.com', password: 'cool'
    UserPages.new(@user).create_page name: 'good-page-name',
      text: 'I wish I had something *interesting* to say!'
    UserPages.new(@user).create_page name: 'cool-interesting-things',
      text: 'Fast cars'
  end

  def search_pages query
    post '/page/search', {query: query}, authenticated_session(@user)
  end

  it 'should integrate the search ok' do
    search_pages 'good'
    text = last_response.body

    assert text.include? '1 pages with matching name'
    assert text.include? 'good-page-name'
    assert text.include? '0 pages with matching text'
  end

  it 'should go directly to the page if a direct match without !' do
    search_pages 'good-page-name'
    follow_redirect_with_authenticated_user!(@user)
    assert last_response.body.include? 'I wish I'
  end

  it 'should not go directly to the page if query had a ! at the end' do
    search_pages 'good-page-name!'
    text = last_response.body
    assert text.include? '1 pages with matching name'
  end

end
