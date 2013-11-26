class SearchQueryParser < Struct.new(:query)

  TAGS_REGEX_STR = "\\s+tags:([a-z\\-][a-z\\-,*]+)"
  FORCE_FULL_SEARCH_REGEX_STR = "!$"

  def search_string
    search_string_unprocessed.gsub(/#{FORCE_FULL_SEARCH_REGEX_STR}/, "")
  end

  def force_full_search
    !! search_string_unprocessed.match(/#{FORCE_FULL_SEARCH_REGEX_STR}/)
  end

  def search_string_unprocessed
    if m = query.match(/^(.+?)(?:#{TAGS_REGEX_STR})/)
      m[1]
    else
      query
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
