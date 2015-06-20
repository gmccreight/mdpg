# Only actually run coveralls in a CI environment.  The code slows down
# tests by 0.4 seconds otherwise.
# This code was copied/pasted from /lib/coveralls.rb in the coveralls-ruby gem
if ENV['CI'] || ENV['JENKINS_URL'] || ENV['COVERALLS_RUN_LOCALLY']
  require 'coveralls'
  Coveralls.wear!
end

require 'mdpg'
require 'minitest/autorun'

def memory_datastore
  @data ||= DataStore.new :memory
end

def create_clan(data = {})
  name = data.key?(:name) || _random_string_of_length(8)
  Clan.create name: name
end

def create_page(data = {})
  name = data.key?(:name) || _random_string_of_length(8)
  Page.create name: name
end

def create_user(data = {})
  name = data.key?(:name) || 'Jordan'
  User.create name: name
end

def _random_string_of_length(length)
  (0...length).map { (65 + rand(26)).chr }.join.downcase
end
