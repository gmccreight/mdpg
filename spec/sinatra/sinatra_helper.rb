ENV['RACK_ENV'] = 'test'

require 'rack/test'

require File.expand_path '../../shared_spec_helper.rb', __FILE__

require File.expand_path '../../../app.rb', __FILE__

include Rack::Test::Methods

def app
  Sinatra::Application
end
