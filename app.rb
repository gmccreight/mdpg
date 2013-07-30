require 'sinatra'
require 'haml'
require 'coffee-script'
require 'json'

$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/lib")
require 'wnp'

if ! $data_store
  $data_store = DataStore.new "./.app_data"
end

enable :sessions

get '/' do
  if current_user
    user_pages = UserPages.new(current_user)
    page_ids_and_names = user_pages.page_ids_and_names_sorted_by_name
    tags = UserPageTags.new(current_user, nil).get_tags()
    haml :index, :locals => {:user => current_user,
      :page_ids_and_names => page_ids_and_names,
      :tags => tags
    }
  else
    redirect to('/login')
  end
end

get '/application.js' do
  coffee :application
end

get '/login' do
  haml :login
end

post '/login' do
  user = User.authenticate params[:email], params[:password]
  if user
    session[:access_token] = user.access_token
  end
  redirect to('/')
end

get '/p/:name' do |page_name|
  if page = get_user_page(page_name)
    pageView = PageView.new(current_user, page)
    haml :page, :locals => {:viewmodel => pageView}
  end
end

get '/p/:name/edit' do |page_name|
  if page = get_user_page(page_name)
    haml :page_edit, :locals => {:page => page}
  end
end

get '/p/:name/tags' do |page_name|
  if page = get_user_page(page_name)
    object_tags = ObjectTags.new(page)
    return object_tags.sorted_tag_names().map{|tag| {:text => tag} }.to_json
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
    page.text = params[:text]
    page.save
    redirect to("/p/#{page.name}")
  end
end

get '/page/add' do
  authorize!
  haml :page_add
end

post '/page/add' do
  authorize!
  user_pages = UserPages.new(current_user)
  page = user_pages.create_page name:params["name"], text:""
  if page
    redirect to("/p/#{page.name}")
  else
    redirect to("/page/add")
  end
end

def get_user_page page_name
  authorize!
  user_pages = UserPages.new(current_user)
  page = user_pages.find_page_with_name page_name
  if page
    return page
  else
    error "could not find that page"
  end
end

def attr_for_request_payload attr
  request.body.rewind
  request_payload = JSON.parse request.body.read
  request_payload[attr]
end

def current_user
  if session[:access_token]
    if user = User.find_by_index(:access_token,
      session[:access_token])
      return user
    else
      session.delete :access_token
    end
  end
  nil
end

def authorize!
  redirect '/login' unless current_user
end
