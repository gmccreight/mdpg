class SearchQueryParser < Struct.new(:query)
  TAGS_REGEX_STR = '\\s+tags:([a-z\\-][a-z\\-,*]+)'
  SHOULD_FORCE_FULL_SEARCH_REGEX_STR = '!$'
  OPEN_RESULT_IN_EDIT_MODE_REGEX_STR = '\\s+e$'

  def search_strings
    str = orig_search_str
    str = str.gsub(/#{SHOULD_FORCE_FULL_SEARCH_REGEX_STR}/, '')
    str = str.gsub(/#{OPEN_RESULT_IN_EDIT_MODE_REGEX_STR}/, '')
    str = strings_for_string(str)
    str
  end

  def should_force_full_search?
    !orig_search_str.match(/#{SHOULD_FORCE_FULL_SEARCH_REGEX_STR}/).nil?
  end

  def should_open_in_edit_mode?
    !orig_search_str.match(/#{OPEN_RESULT_IN_EDIT_MODE_REGEX_STR}/).nil?
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
