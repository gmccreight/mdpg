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

  def get_page_from_sharing_token page_sharing_token
    page, token_type = PageSharingTokens.find_page_by_token(page_sharing_token)
    if ! page
      _set_redirect_to '/'
    else
      pageView = PageView.new(nil, page, token_type)
      return {:viewmodel => pageView, :mode => :shared}
    end
  end

  def edit_page_from_readwrite_token readwrite_token
    page, token_type = PageSharingTokens.find_page_by_token(readwrite_token)
    if page && token_type == :readwrite
      page_text = PageLinks.new(nil)
        .internal_links_to_page_name_links_for_editing(page.text)
      {:page => page, :page_text => page_text,
        :readwrite_token => readwrite_token}
    end
  end

  def update_page_from_readwrite_token readwrite_token, new_text
    page, token_type = PageSharingTokens.find_page_by_token(readwrite_token)
    if page && token_type == :readwrite
      page.text = new_text
      page.save
      _set_redirect_to "/s/#{readwrite_token}"
    end
  end

  def page_rename page, new_name
    begin
      original_name = page.name
      if UserPages.new(current_user).rename_page(page, new_name)
        UserPages.new(current_user).page_was_updated page
        _set_redirect_to "/p/#{new_name}"
      else
        _set_redirect_to "/p/#{original_name}"
      end
    rescue PageAlreadyExistsException
      _add_error "a page with that name already exists"
    end
  end

  def page_update_text page, new_text
    page.text = PageLinks.new(current_user).
      page_name_links_to_ids(new_text)
    page.save
    UserPages.new(current_user).page_was_updated page
    _set_redirect_to "/p/#{page.name}"
  end

  def page_search query
    searcher = Search.new current_user
    results = searcher.search query

    if results[:redirect]
      maybe_edit_mode = results[:redirect_to_edit_mode] ? "/edit" : ""
      _set_redirect_to "/p/#{results[:redirect]}#{maybe_edit_mode}"
      return
    end

    {
      :pages_where_name_matches => results[:names],
      :pages_where_text_matches => results[:texts],
      :tags_where_name_matches =>  results[:tags],
      :user => current_user
    }
  end

  def root
    if ! current_user
      _set_redirect_to '/login'
      return
    end
    user_pages = UserPages.new(current_user)
    tags = UserPageTags.new(current_user, nil).get_tags()
    {:user => current_user, :pages => user_pages.pages, :tags => tags}
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
