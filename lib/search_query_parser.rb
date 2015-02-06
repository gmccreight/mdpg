class SearchQueryParser < Struct.new(:query)

  TAGS_REGEX_STR = "\\s+tags:([a-z\\-][a-z\\-,*]+)"
  SHOULD_FORCE_FULL_SEARCH_REGEX_STR = "!$"
  OPEN_RESULT_IN_EDIT_MODE_REGEX_STR = "\\s+e$"

  def search_string
    str = _orig_search_str
    str = str.gsub(/#{SHOULD_FORCE_FULL_SEARCH_REGEX_STR}/, "")
    str = str.gsub(/#{OPEN_RESULT_IN_EDIT_MODE_REGEX_STR}/, "")
    str
  end

  def should_force_full_search?
    !! _orig_search_str.match(/#{SHOULD_FORCE_FULL_SEARCH_REGEX_STR}/)
  end

  def should_open_in_edit_mode?
    !! _orig_search_str.match(/#{OPEN_RESULT_IN_EDIT_MODE_REGEX_STR}/)
  end

  def tags
    if m = query.match(TAGS_REGEX_STR)
      tag_string = m[1]
      tags = tag_string.split(/,/)
      return tags
    end
    []
  end

  private def _orig_search_str
    if m = query.match(/^(.+?)(?:#{TAGS_REGEX_STR})/)
      m[1]
    else
      query
    end
  end

end
