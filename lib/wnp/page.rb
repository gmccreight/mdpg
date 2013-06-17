require 'wnp/token'

module Wnp

  class Page < Struct.new(:env, :id, :name, :text, :revision)

    def create(name)
      new_page_id = get_max_page_id() + 1
      new_page = Page.new(env, new_page_id, name, "", 0)
      if new_page.save()
        env.user.add_page(new_page.id)
        set_max_page_id(new_page_id)
      end
    end

    def set_max_page_id(val)
      env.data.set('pages-max-page-id', val)
    end

    def get_max_page_id
      env.data.get('pages-max-page-id') || 0
    end

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

    def revision_number_filename
      "#{DATA_PREFIX}-#{id}-revision"
    end

    def page_filename
      "#{DATA_PREFIX}-#{id}-#{revision}"
    end

  end

end
