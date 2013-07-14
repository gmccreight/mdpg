Dir[File.dirname(__FILE__) + '/wnp/*.rb'].each {|file| require file }
Dir[File.dirname(__FILE__) + '/wnp/models/*.rb'].each {|file| require file }
Dir[File.dirname(__FILE__) + '/wnp/services/*.rb'].each {|file| require file }
Dir[File.dirname(__FILE__) + '/wnp/viewmodels/*.rb'].each {|file| require file }

module Wnp

end
