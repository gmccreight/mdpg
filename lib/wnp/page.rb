require 'wnp/token'

module Wnp

  class Page < Struct.new(:id, :name)

    def validate_name
      Wnp::Token.new(name).validate
    end

    def self.get(data, id)
      data = data.get "page-#{id}"
      self.new(data[:id], data[:name])
    end

  end

end
