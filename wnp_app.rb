require 'sinatra'
require 'haml'

$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/lib")
require 'wnp'

if ! $data_store
  $data_store = Wnp::Data.new "./app_data"
end

enable :sessions

get '/' do
  if current_user
    page_ids_and_names = Wnp::Services::UserPages.new(current_user).page_ids_and_names_sorted_by_name
    haml :index, :locals => {:user => current_user, :page_ids_and_names => page_ids_and_names}
  else
    redirect to('/login')
  end
end

get '/login' do
  haml :login
end

post '/login' do
  user = Wnp::Models::User.authenticate params[:email], params[:password]
  if user
    session[:access_token] = user.access_token
  end
  redirect to('/')
end

get '/p/:name' do |page_name|
  authorize!
  user_pages = Wnp::Services::UserPages.new(current_user)
  page = user_pages.find_page_with_name page_name
  if page
    viewmodel = Wnp::Viewmodels::Page.new(current_user, page)
    haml :page, :locals => {:viewmodel => viewmodel}
  else
    "Could not find that page"
  end

end

def current_user
  if session[:access_token]
    if user = Wnp::Models::User.find_by_index(:access_token, session[:access_token])
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
