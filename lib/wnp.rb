([""] + %w{models/ services/ viewmodels/}).each do |x|
  Dir[File.dirname(__FILE__) + "/wnp/#{x}*.rb"].each {|f| require f }
end
