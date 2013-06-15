require 'wnp/token'

module Wnp

  class Page < Struct.new(:data, :id, :name, :text, :revision)

    DATA_PREFIX = "page"

    def save
      if error = validate_name()
        return false
      end

      new_revision = revision + 1
      data.set "#{DATA_PREFIX}-#{id}-#{new_revision}", {:id => id, :name => name, :text => text, :revision => new_revision}
      data.set "#{DATA_PREFIX}-#{id}-revision", new_revision
      true
    end

    def validate_name
      Wnp::Token.new(name).validate
    end

    def self.get(data, id)
      revision = data.get("#{DATA_PREFIX}-#{id}-revision") || 0
      page_name = "#{DATA_PREFIX}-#{id}-#{revision}"
      attrs = data.get(page_name)
      self.new(data, attrs[:id], attrs[:name], attrs[:text], attrs[:revision])
    end

  end

end
