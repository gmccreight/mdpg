require 'sinatra'
require 'haml'

$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/lib")
require 'wnp'

enable :sessions

get '/' do
  haml :index, :locals => {:user => current_user}
end

get '/login' do
  "Login form"
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
    page_view_model = Wnp::Viewmodels::Page.new(current_user, page)
    page_view_model.rendered_html()
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
