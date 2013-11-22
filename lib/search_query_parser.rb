class SearchQueryParser < Struct.new(:query)

  TAGS_REGEX_STR = "\\s+tags:([a-z\\-][a-z\\-,*]+)"

  def search_string
    if m = query.match(/^(.+?)(?:#{TAGS_REGEX_STR})/)
      return m[1]
    else
      return query
    end
  end

  def tags
    if m = query.match(TAGS_REGEX_STR)
      tag_string = m[1]
      tags = tag_string.split(/,/)
      return tags
    end
    []
  end

end
