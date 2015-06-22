require 'similar_token_finder'

class TagAlreadyExistsForPageException < Exception
end

class UserPageTags < Struct.new(:user, :page)
  def add_tag(tag_name)
    if Token.new(tag_name).validate
      return false
    end

    if ObjectTags.new(page).add_tag tag_name
      h = tags_hash
      unless h.key?(tag_name)
        h[tag_name] = {}
      end
      h[tag_name][page.id.to_s] = true
      _set_tags_hash h
      true
    else
      false
    end
  end

  def remove_tag(tag_name)
    if Token.new(tag_name).validate
      return false
    end

    if ObjectTags.new(page).remove_tag tag_name
      remove_tag_from_tags_hash tag_name
      true
    else
      false
    end
  end

  private def remove_tag_from_tags_hash(tag_name)
    h = tags_hash
    return unless h.key?(tag_name)

    page_id_string = page.id.to_s
    return unless h[tag_name].key?(page_id_string)

    h[tag_name].delete(page_id_string)
    if h[tag_name].keys.size == 0
      h.delete(tag_name)
    end

    _set_tags_hash h
  end

  def change_tag(old, new)
    if add_tag new
      remove_tag old
      return true
    end
    false
  end

  def change_tag_for_all_pages(old, new)
    pages = get_pages_for_tag_with_name old

    pages.each do |x|
      user_page_tags = UserPageTags.new(user, x)
      if user_page_tags.has_tag_with_name?(new)
        fail TagAlreadyExistsForPageException
      end
    end

    pages.each do |x|
      user_page_tags = UserPageTags.new(user, x)
      user_page_tags.change_tag old, new
    end
  end

  def duplicate_tags_to_other_page(dest_page)
    new_user_page_tags = self.class.new(user, dest_page)
    tags_for_page(page).each do |tag|
      new_user_page_tags.add_tag tag.name
    end
  end

  def sorted_associated_tags(tag_name)
    counts = _associated_tags_counts tag_name
    counts.to_a.sort do |a, b|
      comp = (b[1] <=> a[1])
      comp.zero? ? (a[0] <=> b[0]) : comp
    end
  end

  def search(query)
    query.downcase!
    SimilarTokenFinder.new.get_similar_tokens(query, get_tag_names)
  end

  def remove_all
    get_tag_names.each do |tag_name|
      remove_tag tag_name
    end
  end

  def get_tag_names
    tags_hash.keys.sort
  end

  def has_tag_with_name?(tag_name)
    tags_hash.key?(tag_name)
  end

  def get_pages_for_tag_with_name(tag_name)
    hash = tags_hash
    if hash.key?(tag_name)
      hash[tag_name].keys.map { |id_string| Page.find(id_string.to_i) }
    else
      return []
    end
  end

  def tag_count(tag)
    h = tags_hash
    return 0 unless h.key?(tag)
    return h[tag].keys.size
  end

  def tags_for_page(x)
    ObjectTags.new(x).get_tags
  end

  private def tags_hash
    h = user.page_tags || {}
    h.default = {}
    h
  end

  private def _set_tags_hash(tags_hash)
    user.page_tags = tags_hash
    user.save
  end

  private def _associated_tags_counts(tag_name)
    count_for = {}
    count_for.default = 0

    tags_on_current_page = []

    pages = get_pages_for_tag_with_name tag_name

    pages.each do |page_in_loop|
      tags_for_page(page_in_loop).each do |tag|
        if page_in_loop.id == page.id
          tags_on_current_page << tag.name
        else
          count_for[tag.name] += 1
        end
      end
    end

    tags_on_current_page.each do |current_page_tag_name|
      count_for.delete(current_page_tag_name)
    end

    count_for
  end
end
