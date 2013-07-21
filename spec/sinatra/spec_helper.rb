ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'

require 'rack/test'

require File.expand_path '../../../wnp_app.rb', __FILE__

include Rack::Test::Methods

def app
  Sinatra::Application
end

def create_user data = {}
  name = data.has_key?(:name) || "Jordan"
  Wnp::Models::User.create name:name
end

def get_memory_datastore
  @data ||= Wnp::Data.new :memory
end
