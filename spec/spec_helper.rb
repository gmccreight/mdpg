require "wnp"

require "minitest/autorun"

def get_data
  @data ||= Wnp::Data.new :memory
end

def get_env
  user = create_user 1
  Wnp::Env.new(get_data(), user)
end

def create_user id, data = {}
  get_data().set "userdata-#{id}", data
  Wnp::User.new get_data(), id
end

def create_page data = {}
  data[:name] = random_string_of_length(8) if !data.has_key?(:name)
  Wnp::Page.create(get_env(), data)
end

def create_group id, data = {}
  get_data().set "groupdata-#{id}", data
  Wnp::Group.new get_data(), id
end

def random_string_of_length length
  (0...length).map{(65+rand(26)).chr}.join.downcase
end
