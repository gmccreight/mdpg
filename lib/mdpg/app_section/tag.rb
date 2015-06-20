module AppSection

  class Tag

    def initialize(app, user = nil)
      @app = app
      @current_user = user
    end

    def current_user
      @current_user
    end

    def get_details tag_name
      user_page_tags = UserPageTags.new(current_user, nil)
      if user_page_tags.get_pages_for_tag_with_name(tag_name).size > 0
        return {:user => current_user, :tag_name => tag_name}
      else
        @app.add_error "you do not have any pages tagged '#{tag_name}'"
      end
    end

    def rename tag_name, new_name
      begin
        UserPageTags.new(current_user, nil)
          .change_tag_for_all_pages(tag_name, new_name)
        @app.set_redirect_to '/'
      rescue TagAlreadyExistsForPageException
        @app.add_error
          'a tag with that name already exists on some of the pages'
      end

    end

  end

end
