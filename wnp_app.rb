require 'sinatra'

$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/lib")
require 'wnp'

get '/' do
  redirect "/p/foobar", 303
end

get '/p/:name' do |n|
  page = Wnp::Page.new(n)
  if error = page.validate_name()
    return "has error #{error} for page name #{n}"
  end
  "You're looking at page #{page.name}"
end
