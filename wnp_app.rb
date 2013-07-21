require 'sinatra'

$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/lib")
require 'wnp'

enable :sessions

get '/p/:name' do |page_name|
  user = Wnp::Models::User.find_by_index :access_token, session[:access_token]
  if ! user
    return "Could not find that user"
  end

  user_pages = Wnp::Services::UserPages.new(user)
  page = user_pages.find_page_with_name page_name
  if page
    page_view_model = Wnp::Viewmodels::Page.new(user, page)
    page_view_model.rendered_html()
  else
    "Could not find that page"
  end

end
