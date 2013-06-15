require 'sinatra'
require './wnpapp'

get '/' do
  redirect "/p/foobar", 303
end

get '/p/:name' do |n|
  page = Wnppage.new(n)
  if error = page.validate_name()
    return "has error #{error} for page name #{n}"
  end
  "You're looking at page #{page.name}"
end
