require 'wnp/token'

module Wnp

  class Page < Struct.new(:env, :id, :name, :text, :revision)

    DATA_PREFIX = "page"

    def save
      if error = validate_name()
        return false
      end

      self.revision += 1
      #a struct to_h is a [tag:ruby2:gem] feature!
      env.data.set page_filename, self.to_h
      env.data.set revision_number_filename(), revision
      true
    end

    def validate_name
      Wnp::Token.new(name).validate
    end

    def load
      self.revision = get_revision()
      attrs = env.data.get(page_filename)

      # for some reason I can't seem to get these to work when looping through
      # the persistable_attributes... so I'm leaving them like this for now.
      self.name = attrs[:name]
      self.text = attrs[:text]
      self.revision = attrs[:revision]
    end

    def get_revision
      env.data.get(revision_number_filename()) || 0
    end

    def user_id
      env.user.id
    end

    def revision_number_filename
      "#{DATA_PREFIX}-#{user_id}-#{id}-revision"
    end

    def page_filename
      "#{DATA_PREFIX}-#{user_id}-#{id}-#{revision}"
    end

  end

end
