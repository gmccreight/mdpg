class App

  attr_accessor :current_user, :errors
  attr_reader :redirect_to

  def initialize(user = nil)
    @current_user = user
    @errors = []
    @redirect_to = nil
  end

  def had_error?
    errors().size > 0
  end

  def errors_message
    errors().join(", ")
  end

  def rename_page_sharing_token(page, token_type, new_token)
    begin
      error_message = PageSharingTokens.new(page).
        rename_sharing_token(token_type, new_token)
      if error_message == nil
        UserPages.new(current_user).page_was_updated page
        _set_redirect_to "/p/#{page.name}"
      else
        _add_error error_message.to_s
      end
    rescue SharingTokenAlreadyExistsException
      _add_error "a page with that token already exists"
    end
  end

  def recent_pages
    edited_pages = _recent_pages_for(current_user.recent_edited_page_ids)
    viewed_pages = _recent_pages_for(current_user.recent_viewed_page_ids)
    {:edited_pages => edited_pages, :viewed_pages => viewed_pages}
  end

  def page_add name
    user_pages = UserPages.new(current_user)
    page = user_pages.create_page name:name, text:""
    path = page ? "/p/#{page.name}/edit" : "/"
    _set_redirect_to path
  end

  private

    def _set_redirect_to path
      @redirect_to = path
    end

    def _add_error error
      errors << error.to_s
    end

    def _recent_pages_for page_ids
      ids = page_ids || []
      ids[0..50].map{|id| Page.find(id)}
    end

end
