# For some reason, the production app crashes if you don't have this line:
# Perhaps look into removing it after upgrading to ruby 2.1 on the server.
require "mdpg/models/base"

([""] + %w{models/ services/ viewmodels/}).each do |x|
  Dir[File.dirname(__FILE__) + "/mdpg/#{x}*.rb"].each {|f| require f }
end
