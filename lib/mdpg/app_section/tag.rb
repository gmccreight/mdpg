# frozen_string_literal: true

module AppSection
  class Tag
    def initialize(app, user = nil)
      @app = app
      @current_user = user
    end

    attr_reader :current_user

    def get_details(tag_name)
      user_page_tags = UserPageTags.new(current_user, nil)
      if user_page_tags.get_pages_for_tag_with_name(tag_name).size > 0
        return { user: current_user, tag_name: tag_name }
      else
        @app.add_error "you do not have any pages tagged '#{tag_name}'"
      end
    end

    def rename(tag_name, new_name)
      UserPageTags.new(current_user, nil)
        .change_tag_for_all_pages(tag_name, new_name)
      @app.redirect_to_path '/'
    rescue TagAlreadyExistsForPageException
      @app.add_error
      'a tag with that name already exists on some of the pages'
    end
  end
end
