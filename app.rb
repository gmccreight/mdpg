require 'sinatra'
require 'haml'
require 'coffee-script'
require 'json'

$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/lib")
require 'mdpg'

if ! $data_store
  $data_store = DataStore.new "./.app_data"
end

if ENV["mdpg_production"]
  set :port, 80
  set :environment, :production
end

get '/' do
  if current_user
    user_pages = UserPages.new(current_user)
    tags = UserPageTags.new(current_user, nil).get_tags()
    haml :index, :locals => {:user => current_user,
      :pages => user_pages.pages,
      :tags => tags
    }
  else
    redirect to('/login')
  end
end

get '/application.js' do
  coffee :application
end

get '/application_spec.js' do
  coffee :application_spec
end

get '/login' do
  haml :login
end

post '/login' do
  user = User.authenticate params[:email], params[:password]
  if user
    set_access_token user.access_token
  end
  redirect to('/')
end

get '/logout' do
  clear_access_token()
  redirect to('/')
end

get '/s/:name' do |page_sharing_token|
  page = Page.find_by_index(:readonly_sharing_token, page_sharing_token)
  if ! page
    page = Page.find_by_index(:readwrite_sharing_token, page_sharing_token)
  end

  if page
    pageView = PageView.new(nil, page)
    haml :page, :locals => {:viewmodel => pageView, :mode => :shared}
  else
    redirect to('/')
  end
end

get '/p/:name' do |page_name|
  if page = get_user_page(page_name)
    pageView = PageView.new(current_user, page)
    haml :page, :locals => {:viewmodel => pageView, :mode => :normal}
  end
end

get '/p/:name/edit' do |page_name|
  if page = get_user_page(page_name)
    page_text = PageLinks.new(current_user)
      .internal_links_to_page_name_links_for_editing(page.text)
    haml :page_edit, :locals => {:page => page, :page_text => page_text}
  end
end

get '/p/:name/tags' do |page_name|
  if page = get_user_page(page_name)
    object_tags = ObjectTags.new(page)
    user_page_tags = UserPageTags.new(current_user, page)
    sorted_tag_names = object_tags.sorted_tag_names()
    results = sorted_tag_names.map do |tagname|
      {
        :text => tagname,
        :associated => user_page_tags.sorted_associated_tags(tagname)
      }
    end
    results.to_json
  end
end

post '/p/:name/delete' do |page_name|
  if page = get_user_page(page_name)
    UserPages.new(current_user).delete_page page_name
    redirect to("/")
  end
end

post '/p/:name/duplicate' do |page_name|
  if page = get_user_page(page_name)
    new_page = UserPages.new(current_user).duplicate_page page_name
    redirect to("/p/" + new_page.name)
  end
end

post '/p/:name/rename' do |page_name|
  if page = get_user_page(page_name)
    begin
      original_name = page.name
      new_name = params["new_name"]
      if UserPages.new(current_user).rename_page(page, new_name)
        redirect to("/p/#{new_name}")
      else
        redirect to("/p/#{original_name}")
      end
    rescue PageAlreadyExistsException
      error "a page with that name already exists"
    end
  end
end

post '/t/:name/rename' do |tag_name|
  authorize!
  new_name = params["new_name"]
  begin
    UserPageTags.new(current_user, nil)
      .change_tag_for_all_pages(tag_name, new_name)
    redirect to("/")
  rescue TagAlreadyExistsForPageException
    error "a tag with that name already exists on some of the pages"
  end
end

get '/p/:name/tag_suggestions' do |page_name|
  if page = get_user_page(page_name)
    tag_typed = params["tagTyped"]
    tags = PageView.new(current_user, page).tag_suggestions_for(tag_typed)
    return {:tags => tags}.to_json
  end
end

post '/p/:name/tags' do |page_name|
  if page = get_user_page(page_name)
    tag_name = attr_for_request_payload "text"
    pageView = PageView.new(current_user, page)
    if pageView.add_tag(tag_name)
      return {:success => "added tag #{tag_name}"}.to_json
    else
      return {:error => "could not add the tag #{tag_name}"}.to_json
    end
  end
end

delete '/p/:name/tags/:tag_name' do |page_name, tag_name|
  if page = get_user_page(page_name)
    pageView = PageView.new(current_user, page)
    if pageView.remove_tag(tag_name)
      return {:success => "removed tag #{tag_name}"}.to_json
    else
      return {:error => "the tag #{tag_name} could not be deleted"}.to_json
    end
  end
end

post '/p/:name/update' do |page_name|
  if page = get_user_page(page_name)
    page.text = PageLinks.new(current_user).
      page_name_links_to_ids(params[:text])
    page.save
    redirect to("/p/#{page.name}")
  end
end

post '/page/add' do
  authorize!
  user_pages = UserPages.new(current_user)
  page = user_pages.create_page name:params["name"], text:""
  if page
    redirect to("/p/#{page.name}/edit")
  else
    redirect to("/")
  end
end

post '/page/search' do
  authorize!
  searcher = Search.new current_user
  results = searcher.search params[:query]

  haml :page_search, :locals => {
    :pages_where_name_matches => results[:names],
    :pages_where_text_matches => results[:texts],
    :tags_where_name_matches =>  results[:tags],
    :user => current_user
  }
end

def get_user_page page_name
  authorize!
  if page = current_user_page_with_name(page_name)
    return page
  else
    error "could not find that page"
  end
end

def current_user_page_with_name page_name
  user_pages = UserPages.new(current_user)
  user_pages.find_page_with_name page_name
end

def attr_for_request_payload attr
  request.body.rewind
  request_payload = JSON.parse request.body.read
  request_payload[attr]
end

def current_user
  if get_access_token()
    if user = User.find_by_index(:access_token, get_access_token())
      return user
    else
      clear_access_token()
    end
  end
  nil
end

def get_access_token
  request.cookies['access_token']
end

def set_access_token token
  response.set_cookie 'access_token', {:value => token, :max_age => "2592000"}
end

def clear_access_token
  response.set_cookie 'access_token', {:value => '', :max_age => '0'}
end

def authorize!
  redirect '/login' unless current_user
end
