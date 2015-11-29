require 'mdpg/app_section/tag'
require 'mdpg/app_section/page_tag'

class App
  attr_accessor :current_user, :errors
  attr_reader :redirect_to

  def initialize(user = nil)
    @current_user = user
    @errors = []
    @redirect_to = nil
  end

  def tag
    @tag ||= AppSection::Tag.new(self, @current_user)
  end

  def page_tag
    @page_tag ||= AppSection::PageTag.new(self, @current_user)
  end

  def had_error?
    errors.size > 0
  end

  def errors_message
    errors.join(', ')
  end

  def get_page_from_sharing_token(page_sharing_token)
    page, token_type =
      PageSharingTokens.find_page_by_token(page_sharing_token)
    if !page
      redirect_to_path '/'
    else
      page_view = PageView.new(nil, page, token_type)
      return { viewmodel: page_view, mode: :shared }
    end
  end

  def page_get(page)
    page_view = PageView.new(current_user, page, nil)
    UserRecentPages.new(current_user).add_to_recent_viewed_pages_list(page)
    { viewmodel: page_view, mode: :normal }
  end

  def page_edit(page)
    page_text = PageEditView.new(current_user, page).text_for_editing
    { page: page, page_text: page_text, readwrite_token: nil }
  end

  def edit_page_from_readwrite_token(readwrite_token)
    page, token_type = PageSharingTokens.find_page_by_token(readwrite_token)
    return if !page || token_type != :readwrite

    page_text = PageLinks.new(nil)
      .internal_links_to_page_name_links_for_editing(page.text)
    { page: page, page_text: page_text,
      readwrite_token: readwrite_token }
  end

  def page_delete(page)
    UserPages.new(current_user).delete_page page.name
    redirect_to_path '/'
  rescue PageCannotBeDeletedBecauseItHasReferringPages
    add_error 'the page cannot be deleted because other pages refer to it'
  end

  def update_page_from_readwrite_token(readwrite_token, new_text)
    page, token_type = PageSharingTokens.find_page_by_token(readwrite_token)
    return if !page || token_type != :readwrite

    page.text = new_text
    page.save
    redirect_to_path "/s/#{readwrite_token}"
  end

  def page_rename(page, new_name)
    original_name = page.name
    if UserPages.new(current_user).rename_page(page, new_name)
      UserPages.new(current_user).page_was_updated page
      redirect_to_path "/p/#{new_name}"
    else
      redirect_to_path "/p/#{original_name}"
    end
  rescue PageAlreadyExistsException
    add_error 'a page with that name already exists'
  end

  def page_update_text(page, new_text)
    user_pages = UserPages.new(current_user)
    user_pages.update_page_text_to(page, new_text)
    user_pages.page_was_updated page

    redirect_to_path "/p/#{page.name}"
  end

  def page_search(query)
    searcher = Search.new current_user
    results = searcher.search query

    {
      pages_where_name_matches: results[:names],
      pages_where_text_matches: results[:texts],
      tags_where_name_matches: results[:tags],
      user: current_user
    }
  end

  def root
    unless current_user
      redirect_to_path '/login'
      return
    end
    redirect_to_path '/page/recent'
  end

  def update_page_sharing_token(page, token_type, new_token, is_activated)
    if is_activated
      PageSharingTokens.new(page).activate_sharing_token token_type
    else
      PageSharingTokens.new(page).deactivate_sharing_token token_type
    end

    begin
      error_message = PageSharingTokens.new(page)
        .rename_sharing_token(token_type, new_token)
      if error_message.nil?
        UserPages.new(current_user).page_was_updated page
        redirect_to_path "/p/#{page.name}"
      else
        add_error error_message.to_s
      end
    rescue SharingTokenAlreadyExistsException
      add_error 'a page with that token already exists'
    end
  end

  def recent_pages(how_many = 25)
    created =
      _recent_pages_for(current_user.recent_created_page_ids, how_many)
    edited = _recent_pages_for(current_user.recent_edited_page_ids, how_many)
    viewed = _recent_pages_for(current_user.recent_viewed_page_ids, how_many)
    { created_pages: created, edited_pages: edited, viewed_pages: viewed }
  end

  def stats
    pages = UserPages.new(current_user).pages
    { pages: pages }
  end

  def page_add(name)
    user_pages = UserPages.new(current_user)
    page = user_pages.create_page name: name, text: ''
    path = page ? "/p/#{page.name}/edit" : '/'
    redirect_to_path path
  rescue PageAlreadyExistsException
    add_error 'a page with that name already exists'
  end

  def redirect_to_path(path)
    @redirect_to = path
  end

  def add_error(error)
    errors << error.to_s
  end

  private def _recent_pages_for(page_ids, how_many)
    ids = page_ids || []
    ids[0..how_many - 1].map { |id| Page.find(id) }
  end
end
