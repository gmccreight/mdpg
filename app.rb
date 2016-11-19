# frozen_string_literal: true

require 'sinatra'
require 'haml'
require 'coffee-script'
require 'json'

require 'profiler' if ENV['profiler']

# require 'pry-rescue/minitest' #slows down tests, but can be very handy

$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/lib")
require 'mdpg'

unless $data_store
  $data_store = DataStore.new('./.app_data', lru_gc_size_threshold: 2_000)
end

if ENV['mdpg_production']
  set :port, 8080
  set :environment, :production
end

before do
  $data_store.reset_reporting_data
end

# after do
#   puts $data_store.report
# end

get '/' do
  app = authorize!
  results = app.root
  _app_handle_result app
  haml :index, locals: results
end

get '/application.js' do
  cache_control :public, max_age: 600
  coffee :application
end

get '/keyboard.js' do
  cache_control :public, max_age: 600
  coffee :keyboard
end

get '/application_spec.js' do
  coffee :application_spec
end

get '/login' do
  haml :login
end

post '/login' do
  user = User.authenticate params[:email], params[:password]
  self.access_token = user.access_token if user
  redirect '/'
end

get '/logout' do
  clear_access_token
  redirect '/'
end

get '/s/:name' do |page_sharing_token|
  app = _app_get
  result = app.get_page_from_sharing_token page_sharing_token
  _app_handle_result app
  haml :page, locals: result
end

get '/s/:readwrite_token/edit' do |readwrite_token|
  app = _app_get
  result = app.edit_page_from_readwrite_token readwrite_token
  _app_handle_result app
  haml :page_edit, locals: result
end

post '/s/:readwrite_token/update' do |readwrite_token|
  app = _app_get
  app.update_page_from_readwrite_token readwrite_token, params[:text]
  _app_handle_result app
end

get '/p/:name' do |page_name|
  # if ENV["profiler"]
  #   Profiler__.start_profile
  # end

  page = get_user_page(page_name)

  page = page.find(page.id, params[:revision].to_i) if params[:revision]
  if page
    app = _app_get
    haml :page, locals: app.page_get(page)
  end

  # p $data_store.report

  # if ENV["profiler"]
  #   Profiler__.stop_profile
  #   Profiler__.print_profile(STDOUT)
  # end
end

get '/t/:name' do |tag_name|
  app = authorize!
  app.tag.get_details(tag_name)
  _app_handle_result app
  haml :page_tag, locals: app.tag.get_details(tag_name)
end

get '/p/:name/edit' do |page_name|
  page = get_user_page(page_name)

  # Hack to try out woofmark
  page_tags = ObjectTags.new(page)
  params[:woofmark] = 1 if
    page_tags.sorted_tag_names.include?('mdpg-use-woofmark')

  if page
    app = _app_get
    haml :page_edit, locals: app.page_edit(page)
  end
end

get '/p/:name/tags' do |page_name|
  page = get_user_page(page_name)
  if page
    app = _app_get
    return app.page_tag.all_for_page page
  end
end

post '/p/:name/delete' do |page_name|
  page = get_user_page(page_name)
  if page
    app = _app_get
    app.page_delete page
    _app_handle_result app
  end
end

post '/p/:name/duplicate' do |page_name|
  if get_user_page(page_name)
    new_page = UserPages.new(current_user).duplicate_page page_name
    redirect '/p/' + new_page.name
  end
end

post '/p/:name/rename' do |page_name|
  page = get_user_page(page_name)
  if page
    app = _app_get
    app.page_rename page, params[:new_name]
    _app_handle_result app
  end
end

post '/p/:name/update_sharing_token' do |page_name|
  token_type = params[:token_type].to_sym
  new_token = params[:new_token]
  is_activated = params[:is_activated]

  page = get_user_page(page_name)
  if page
    app = _app_get
    app.update_page_sharing_token page, token_type, new_token, is_activated
    _app_handle_result app
  end
end

post '/t/:name/rename' do |tag_name|
  new_name = params[:new_name]

  app = authorize!
  app.tag.rename tag_name, new_name
  _app_handle_result app
end

get '/p/:name/tag_suggestions' do |page_name|
  tag_typed = params[:tagTyped]

  page = get_user_page(page_name)
  if page
    app = _app_get
    return app.page_tag.suggestions page, tag_typed
  end
end

post '/p/:name/tags' do |page_name|
  tag_name = attr_for_request_payload 'text'

  page = get_user_page(page_name)
  if page
    app = _app_get
    return app.page_tag.add(page, tag_name)
  end
end

delete '/p/:name/tags/:tag_name' do |page_name, tag_name|
  page = get_user_page(page_name)
  if page
    app = _app_get
    return app.page_tag.delete(page, tag_name)
  end
end

post '/p/:name/update' do |page_name|
  new_text = params[:text]
  page = get_user_page(page_name)
  if page
    app = authorize!
    app.page_update_text page, new_text
    _app_handle_result app
  end
end

get '/page/recent' do
  app = authorize!
  how_many = params['how_many'] ? params['how_many'].to_i : 25
  haml :page_recent, locals: app.recent_pages(how_many)
end

get '/stats' do
  app = authorize!
  haml :page_stats, locals: app.stats
end

post '/page/add' do
  app = authorize!
  app.page_add(params['name'])
  _app_handle_result app
end

post '/page/search' do
  post_or_get_search
end

get '/page/search' do
  post_or_get_search
end

def post_or_get_search
  app = authorize!
  results = app.page_search(params[:query])
  _app_handle_result app
  haml :page_search, locals: results
end

def get_user_page(page_name)
  authorize!
  page = UserPages.new(current_user).find_page_with_name(page_name)
  if page
    page
  else
    error 'could not find that page'
  end
end

def attr_for_request_payload(attr)
  request.body.rewind
  request_payload = JSON.parse request.body.read
  request_payload[attr]
end

def current_user
  return nil unless access_token

  user = User.find_by_index(:access_token, access_token)
  if user
    return user
  else
    clear_access_token
  end
end

def access_token
  request.cookies['access_token']
end

def access_token=(token)
  response.set_cookie 'access_token', value: token, max_age: '2592000'
end

def clear_access_token
  response.set_cookie 'access_token', value: '', max_age: '0'
end

def authorize!
  redirect '/login' unless current_user
  _app_get
end

def _app_get
  App.new(current_user)
end

def _app_handle_result(app)
  if app.had_error?
    error app.errors_message
  elsif !app.redirect_to.nil?
    redirect app.redirect_to
  end
end
