require 'wnp/token'

module Wnp

  class Page < Struct.new(:name)

    def validate_name
      Wnp::Token.new(name).validate
    end

  end

end
