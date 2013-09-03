require "similar_token_finder"

class TagAlreadyExistsForPageException < Exception
end

class UserPageTags < Struct.new(:user, :page)

  def add_tag tag_name
    if error = Token.new(tag_name).validate
      return false
    end

    if ObjectTags.new(page).add_tag tag_name
      h = get_tags_hash()
      if ! h.has_key?(tag_name)
        h[tag_name] = {}
      end
      h[tag_name][page.id.to_s] = true
      user.page_tags = h
      user.save
      true
    else
      false
    end

  end

  def remove_tag tag_name
    if error = Token.new(tag_name).validate
      return false
    end

    if ObjectTags.new(page).remove_tag tag_name
      h = get_tags_hash()
      if ! h.has_key?(tag_name)
        return
      else
        if h[tag_name].has_key?(page.id.to_s)
          h[tag_name].delete(page.id.to_s)
          if h[tag_name].keys.size == 0
            h.delete(tag_name)
          end
        end
      end

      user.page_tags = h
      user.save
      true
    else
      false
    end

  end

  def change_tag old, new
    if add_tag new
      remove_tag old
      return true
    end
    false
  end

  def change_tag_for_all_pages old, new
    pages = get_pages_for_tag_with_name old

    pages.each do |x|
      user_page_tags = UserPageTags.new(user, x)
      if user_page_tags.has_tag_with_name?(new)
        raise TagAlreadyExistsForPageException
      end
    end

    pages.each do |x|
      user_page_tags = UserPageTags.new(user, x)
      user_page_tags.change_tag old, new
    end
  end

  def search query
    SimilarTokenFinder.new.get_similar_tokens(query, get_tags())
  end

  def remove_all
    get_tags.each do |tag_name|
      remove_tag tag_name
    end
  end

  def get_tags
    get_tags_hash().keys.sort
  end

  def has_tag_with_name? tag
    get_tags_hash().has_key?(tag)
  end

  def get_pages_for_tag_with_name tag
    hash = get_tags_hash()
    if hash.has_key?(tag)
      hash[tag].keys.map{|id_string| Page.find(id_string.to_i)}
    else
      return []
    end
  end

  def tag_count tag
    h = get_tags_hash()
    return 0 if ! h.has_key?(tag)
    return h[tag].keys.size
  end

  private

    def get_tags_hash
      h = user.page_tags || {}
      h.default = {}
      h
    end

end
