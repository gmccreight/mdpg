require File.expand_path '../spec_helper.rb', __FILE__

describe "the wnp app" do
  it "should successfully return the about page" do
    get '/about' 
    assert_equal 'about this', last_response.body 
  end
end
