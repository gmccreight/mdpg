require 'wnp/modules/incrementing_id'
include Wnp::Modules::IncrementingId

module Wnp

  class Page < Struct.new(:env, :id, :name, :text, :revision)

    def self.create env, opts = {}
      p = self.new(env)
      p.create opts
    end

    def create opts = {}
      new_page_id = get_max_id() + 1
      new_page = Page.new(env, new_page_id, opts[:name], opts[:text], 0)
      if new_page.save()
        env.user.add_page(new_page.id)
        set_max_id(new_page_id)
        return new_page
      end
      nil
    end

    def text_contains query
      text.include?(query)
    end

    def name_contains query
      name.include?(query)
    end

    def save
      if error = validate_name()
        return false
      end

      self.revision += 1
      #a struct to_h is a [tag:ruby2:gem] feature!
      env.data.set data_key, self.to_h
      env.data.set revision_number_filename(), revision
      true
    end

    def validate_name
      Wnp::Token.new(name).validate
    end

    def load
      self.revision = get_revision()
      attrs = env.data.get(data_key)

      # for some reason I can't seem to get these to work when looping through
      # the persistable_attributes... so I'm leaving them like this for now.
      self.name = attrs[:name]
      self.text = attrs[:text]
      self.revision = attrs[:revision]
    end

    def get_revision
      env.data.get(revision_number_filename()) || 0
    end

    def revision_number_filename
      "#{get_data_prefix()}-#{id}-revision"
    end

    private

      def data_key
        "#{get_data_prefix()}-#{id}-#{revision}"
      end

      def get_data_prefix
        "pagedata"
      end

  end

end
