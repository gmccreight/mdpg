require File.expand_path '../sinatra_helper.rb', __FILE__

describe "auth" do

  before do
    $data_store = get_memory_datastore()
    @user = User.create name:"Jordan",
      email:"jordan@example.com", password:"cool"
  end

  it "should be fast" do
    if ENV["perf"]
      require 'ruby-prof'

      RubyProf.start

      post '/login', {email:"jordan@example.com", password:"cool"}
      follow_redirect!
      follow_redirect!
      assert last_response.body.include? "Edited"

      result = RubyProf.stop
      printer = RubyProf::FlatPrinter.new(result)
      if ENV["verbose"]
        printer.print(STDOUT)
      end
    end
  end

  it "should move to the recent pages page after auth" do
    post '/login', {email:"jordan@example.com", password:"cool"}
    follow_redirect!
    follow_redirect!
    assert last_response.body.include? "Edited"
  end

  it "should stay logged in and logged out after moving to those states" do
    post '/login', {email:"jordan@example.com", password:"cool"}
    follow_redirect!
    follow_redirect!
    assert last_response.body.include? "Edited"

    get '/'
    follow_redirect!
    assert last_response.body.include? "Edited"

    get '/logout'
    follow_redirect!
    follow_redirect!
    assert last_response.body.include? "Please login"

    get '/'
    follow_redirect!
    assert last_response.body.include? "Please login"
  end

end
