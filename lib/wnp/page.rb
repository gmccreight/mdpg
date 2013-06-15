require 'wnp/token'

module Wnp

  class Page < Struct.new(:data, :id, :name, :text)

    DATA_PREFIX = "page"

    def save
      if error = validate_name()
        return false
      end

      data.set "#{DATA_PREFIX}-#{id}", {:id => id, :name => name, :text => text}
      true
    end

    def validate_name
      Wnp::Token.new(name).validate
    end

    def self.get(data, id)
      attrs = data.get "#{DATA_PREFIX}-#{id}"
      self.new(data, attrs[:id], attrs[:name], attrs[:text])
    end

  end

end
