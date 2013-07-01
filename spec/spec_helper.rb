require "wnp"

require "minitest/autorun"

def get_memory_datastore
  @data ||= Wnp::Data.new :memory
end

def get_env
  user = create_user 1
  Wnp::Env.new(get_memory_datastore(), user)
end

def create_user id, data = {}
  get_memory_datastore().set "userdata-#{id}", data
  Wnp::User.new get_memory_datastore(), id
end

def create_page data = {}
  data[:name] = random_string_of_length(8) if !data.has_key?(:name)
  Wnp::Page.create(get_env(), data)
end

def create_group id, data = {}
  get_memory_datastore().set "groupdata-#{id}", data
  Wnp::Group.new get_memory_datastore(), id
end

def random_string_of_length length
  (0...length).map{(65+rand(26)).chr}.join.downcase
end
