class Page < ModelBase

  attr_accessor :name, :text, :revision, :tag_ids

  def text_contains query
    text.include?(query)
  end

  def name_contains query
    name.include?(query)
  end

  def add_tag tag
    add_associated_object tag
  end

  def remove_tag tag
    remove_associated_object tag
  end

  private
  
    def is_versioned?
      true
    end

    def validates?
      errors = Token.new(name).validate
      return ! errors
    end

end
