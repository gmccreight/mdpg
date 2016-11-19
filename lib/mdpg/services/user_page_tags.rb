# frozen_string_literal: true

require 'similar_token_finder'

class TagAlreadyExistsForPageException < RuntimeError
end

class UserPageTags < Struct.new(:user, :page)
  def initialize(user, page)
    reset_caches
    super(user, page)
  end

  def reset_caches
    @tags_for_page_id = {}
    @page_for_id = {}
    @associated_tags_counts = {}
  end

  def add_tag(tag_name)
    return false if Token.new(tag_name).validate

    if ObjectTags.new(page).add_tag tag_name
      h = tags_hash
      h[tag_name] = {} unless h.key?(tag_name)
      h[tag_name][page.id.to_s] = true
      _set_tags_hash h
      true
    else
      false
    end
  end

  def remove_tag(tag_name)
    return false if Token.new(tag_name).validate

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
    h.delete(tag_name) if h[tag_name].keys.empty?

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
      if user_page_tags.tag_with_name?(new)
        raise TagAlreadyExistsForPageException
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
    SimilarTokenFinder.new.get_similar_tokens(query, tag_names)
  end

  def remove_all
    tag_names.each do |tag_name|
      remove_tag tag_name
    end
  end

  def tag_names
    tags_hash.keys.sort
  end

  def tag_with_name?(tag_name)
    tags_hash.key?(tag_name)
  end

  def get_pages_for_tag_with_name(tag_name)
    hash = tags_hash
    if hash.key?(tag_name)
      hash[tag_name].keys.map { |id_string| page_for_id(id_string.to_i) }
    else
      return []
    end
  end

  def page_for_id(id)
    return @page_for_id[id] if @page_for_id.key?(id)
    @page_for_id[id] = Page.find(id)
    @page_for_id[id]
  end

  def tag_count(tag)
    h = tags_hash
    return 0 unless h.key?(tag)
    h[tag].keys.size
  end

  def tags_for_page(page)
    return @tags_for_page_id[page.id] if @tags_for_page_id.key?(page.id)
    @tags_for_page_id[page.id] = ObjectTags.new(page).tags
    @tags_for_page_id[page.id]
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
    if @associated_tags_counts.key?(tag_name)
      return @associated_tags_counts[tag_name]
    end

    count_for = {}
    count_for.default = 0

    tagnames_on_current_page = []

    pages = get_pages_for_tag_with_name tag_name

    pages.each do |page_in_loop|
      tags_for_page(page_in_loop).each do |tag|
        if page_in_loop.id == page.id
          tagnames_on_current_page << tag.name
        else
          count_for[tag.name] += 1
        end
      end
    end

    # Don't show the tags that are already on the current page
    tagnames_on_current_page.each { |x| count_for.delete(x) }

    @associated_tags_counts[tag_name] = count_for

    count_for
  end
end
