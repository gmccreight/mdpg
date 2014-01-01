require "mdpg/models/base"
require "mdpg/app"

([""] + %w{models/ services/ viewmodels/}).each do |x|
  Dir[File.dirname(__FILE__) + "/mdpg/#{x}*.rb"].each {|f| require f }
end
