require 'wnp/token'

module Wnp

  class Page < Struct.new(:env, :id, :name, :text, :revision)

    DATA_PREFIX = "page"

    def save
      if error = validate_name()
        return false
      end

      new_revision = revision + 1
      env.data.set "#{DATA_PREFIX}-#{user_id}-#{id}-#{new_revision}", {:id => id, :name => name, :text => text, :revision => new_revision}
      env.data.set get_revision_filename(), new_revision
      true
    end

    def validate_name
      Wnp::Token.new(name).validate
    end

    def load
      revision = get_revision()
      page_name = "#{DATA_PREFIX}-#{user_id}-#{id}-#{revision}"
      attrs = env.data.get(page_name)
      self.name = attrs[:name]
      self.text = attrs[:text]
      self.revision = attrs[:revision]
    end

    def get_revision
      env.data.get(get_revision_filename()) || 0
    end

    def user_id
      env.user.id
    end

    def get_revision_filename
      "#{DATA_PREFIX}-#{user_id}-#{id}-revision"
    end

  end

end
