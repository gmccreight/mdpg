class Page < ModelBase

  attr_accessor :name, :text, :revision, :tag_ids, :readonly_sharing_token,
    :readwrite_sharing_token

  def text_contains query
    text.include?(query.downcase)
  end

  def name_contains query
    name.include?(query.downcase)
  end

  def add_tag tag
    add_associated_object tag
  end

  def remove_tag tag
    remove_associated_object tag
  end

  def save
    ensure_has_sharing_token :readonly_sharing_token
    ensure_has_sharing_token :readwrite_sharing_token
    super
  end

  private

    def unique_id_indexes
      [:readonly_sharing_token, :readwrite_sharing_token]
    end

    def is_versioned?
      true
    end

    def validates?
      errors = Token.new(name).validate
      return ! errors
    end

    def ensure_has_sharing_token token_name
      if ! self.send(token_name)
        self.send("#{token_name}=",
          RandStringGenerator.rand_string_of_length(32))
      end
    end

end
