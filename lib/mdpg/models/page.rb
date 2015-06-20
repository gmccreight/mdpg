class Page < ModelBase

  ATTRS = [:name, :text, :revision, :tag_ids, :readonly_sharing_token,
    :readwrite_sharing_token, :readonly_sharing_token_activated,
    :readwrite_sharing_token_activated, :referring_page_ids,
    :refers_to_page_ids]

  attr_accessor(*ATTRS)

  def text_contains?(query)
    string_contains? text.downcase, query.downcase
  end

  def name_contains?(query)
    string_contains? name, query.downcase
  end

  def add_tag(tag)
    add_associated_object tag
  end

  def remove_tag(tag)
    remove_associated_object tag
  end

  def has_any_referring_pages?
    referring_page_ids && referring_page_ids.size > 0
  end

  def meta
    meta_line = text.lines.select { |x| x =~ /^mdpg-meta:\{/ }.first
    return nil if !meta_line
    json_data = meta_line.sub(/^mdpg-meta:/, '')
    JSON.parse(json_data, symbolize_names: true)
  end

  private def string_contains?(string, query)
    string.include? query
  end

  private def unique_id_indexes
    [:readonly_sharing_token, :readwrite_sharing_token]
  end

  private def attr_defaults
    {
      readonly_sharing_token:
        Proc.new { RandStringGenerator.rand_string_of_length(32) },
      readwrite_sharing_token:
        Proc.new { RandStringGenerator.rand_string_of_length(32) },
      referring_page_ids: [],
      text: ''
    }
  end

  private def is_versioned?
    true
  end

  private def validates?
    errors = Token.new(name).validate
    return !errors
  end

end
