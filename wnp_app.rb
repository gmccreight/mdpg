require 'sinatra'

$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/lib")
require 'wnp'

enable :sessions

get '/p/:name' do |n|
  user = Wnp::Models::User.find_by_index :access_token, session[:access_token]
  if user
    user_pages = Wnp::Services::UserPages.new(user)
    page = user_pages.find_page_with_name n
    if page
      "You're looking at page #{page.name}"
    else
      "Could not find that page"
    end
  else
    "Could not find that user"
  end
end
