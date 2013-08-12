require "mdpg/models/base"

([""] + %w{models/ services/ viewmodels/}).each do |x|
  Dir[File.dirname(__FILE__) + "/mdpg/#{x}*.rb"].each {|f| require f }
end
