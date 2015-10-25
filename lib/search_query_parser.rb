class SearchQueryParser < Struct.new(:query)
  TAGS_REGEX_STR = '\\s+tags:([a-z\\-][a-z\\-,*]+)'

  def search_strings
    str = orig_search_str
    str = strings_for_string(str)
    str
  end

  def tags
    m = query.match(TAGS_REGEX_STR)
    if m
      tag_string = m[1]
      tags = tag_string.split(/,/)
      return tags
    end
    []
  end

  private def strings_for_string(str)
    are_multiple_tokens_required = false
    str = str.gsub(/^\+\s*/) do
      are_multiple_tokens_required = true
      ''
    end

    if are_multiple_tokens_required
      str.split(/\s+/)
    else
      [str]
    end
  end

  private def orig_search_str
    m = query.match(/^(.+?)(?:#{TAGS_REGEX_STR})/)
    if m
      m[1]
    else
      query
    end
  end
end
