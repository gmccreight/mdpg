require 'mdpg/token'

class ObjectTags < Struct.new(:object)

  def initialize(object)
    reset_caches
    super(object)
  end

  def reset_caches
    @tags = []
    @tags_cached_ids = []
    @tag_with_name = {}
  end

  def add_tag(name)
    return false if Token.new(name).validate

    return false if tag_with_name?(name)

    tag = Tag.find_by_index(:name, name) ||
      Tag.create(name: name)

    tag.add_associated_object object
    tag.save
    object.add_tag tag
    object.save
    reset_caches
  end

  def remove_tag(name)
    return false if Token.new(name).validate

    tag = tag_with_name(name)
    return unless tag

    tag.remove_associated_object object
    tag.save
    object.remove_tag tag
    object.save
  end

  def tag_with_name?(name)
    !tag_with_name(name).nil?
  end

  def tag_with_name(name)
    if @tag_with_name.key?(name)
      return @tag_with_name[name]
    end
    tags_with_name = tags.select { |tag| tag.name == name }
    if tags_with_name.size > 0
      @tag_with_name[name] = tags_with_name.first
      return @tag_with_name[name]
    else
      @tag_with_name[name] = nil
      return nil
    end
  end

  def tags
    return [] unless object.tag_ids

    if @tags_cached_ids != object.tag_ids
      @tags = object.tag_ids.map { |x| Tag.find(x) }
      @tags_cached_ids = object.tag_ids
      return @tags
    else
      # use the cached value
      return @tags
    end
  end

  def sorted_tag_names
    tags.map(&:name).sort
  end
end
