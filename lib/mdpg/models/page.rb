class Page < ModelBase

  ATTRS = [:name, :text, :revision, :tag_ids, :readonly_sharing_token,
    :readwrite_sharing_token, :readonly_sharing_token_activated,
    :readwrite_sharing_token_activated, :referring_page_ids,
    :refers_to_page_ids]

  attr_accessor *ATTRS

  def text_contains? query
    string_contains? text.downcase, query.downcase
  end

  def name_contains? query
    string_contains? name, query.downcase
  end

  def add_tag tag
    add_associated_object tag
  end

  def remove_tag tag
    remove_associated_object tag
  end

  def has_any_referring_pages?
    referring_page_ids && referring_page_ids.size > 0
  end

  def save
    ensure_has_sharing_token :readonly_sharing_token
    ensure_has_sharing_token :readwrite_sharing_token
    ensure_has_referring_page_ids
    ensure_has_refers_to_page_ids
    super
  end

  private def string_contains? string, query
    string.include? query
  end

  private def unique_id_indexes
    [:readonly_sharing_token, :readwrite_sharing_token]
  end

  private def is_versioned?
    true
  end

  private def validates?
    errors = Token.new(name).validate
    return ! errors
  end

  private def ensure_has_sharing_token token_name
    if ! self.send(token_name)
      self.send("#{token_name}=",
        RandStringGenerator.rand_string_of_length(32))
    end
  end

  private def ensure_has_referring_page_ids
    if ! self.referring_page_ids
      self.referring_page_ids = []
    end
  end

  private def ensure_has_refers_to_page_ids
    if ! self.refers_to_page_ids
      self.refers_to_page_ids = []
    end
  end

end
