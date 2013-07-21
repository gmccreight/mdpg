require File.expand_path '../spec_helper.rb', __FILE__

describe "auth" do

  before do
    $data_store = get_memory_datastore()
    @user = Wnp::Models::User.create name:"Jordan", email:"jordan@example.com", password:"cool"
  end

  it "should a message on the homepage after auth" do
    post '/login', {email:"jordan@example.com", password:"cool"}
    follow_redirect!
    assert last_response.body.include? "Hello, Jordan"
  end

end
