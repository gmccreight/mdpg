ENV['RACK_ENV'] = 'test'

class LastResponseWasNotRedirectException < Exception
end

require 'rack/test'

require File.expand_path '../../shared_spec_helper.rb', __FILE__

require File.expand_path '../../../app.rb', __FILE__

include Rack::Test::Methods

def app
  Sinatra::Application
end

def authenticated_session(user)
  { 'HTTP_COOKIE' => "access_token=#{user.access_token}" }
end

def follow_redirect_with_authenticated_user!(user)
  fail LastResponseWasNotRedirectException unless last_response.redirect?
  auth_cookie = authenticated_session(user)
  get(last_response['Location'], {},
      { 'HTTP_REFERER' => last_request.url }.merge(auth_cookie))
end
