require "wnp"
require "minitest/autorun"

def get_memory_datastore
  @data ||= DataStore.new :memory
end

def create_group data = {}
  name = data.has_key?(:name) || _random_string_of_length(8)
  Wnp::Models::Group.create name:name
end

def create_page data = {}
  name = data.has_key?(:name) || _random_string_of_length(8)
  Wnp::Models::Page.create name:name
end

def create_user data = {}
  name = data.has_key?(:name) || "Jordan"
  Wnp::Models::User.create name:name
end

def _random_string_of_length length
  (0...length).map{(65+rand(26)).chr}.join.downcase
end
