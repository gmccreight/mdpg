# frozen_string_literal: true

class DuplicatorDatePageAlreadyExists < RuntimeError
end

class UserPageDuplicator < Struct.new(:user_pages, :user, :original_page)
  def duplicate(current_date)
    new_page_name = new_name(original_page.name, current_date)
    new_page = user_pages.create_page(name: new_page_name)

    user_pages.update_page_text_to(new_page, original_page.text)

    user_page_tags = UserPageTags.new(user, original_page)
    user_page_tags.duplicate_tags_to_other_page(new_page)

    new_page.save
    new_page
  end

  private def new_name(name, current_date)
    date_regex = %r{-[0-9]{4}-[0-9]{2}-[0-9]{2}$}
    if name =~ date_regex
      result = name.sub(date_regex, '-' + current_date.to_s)
      if user_pages.find_page_with_name(result)
        raise DuplicatorDatePageAlreadyExists
      else
        return result
      end
    else
      increment = 2
      result = propose_incremented_name_for(name, increment)
      while user_pages.find_page_with_name(result)
        increment += 1
        result = propose_incremented_name_for(name, increment)
      end
      return result
    end
  end

  private def propose_date_name_for(name, increment)

    version_suffix_regex = /-(v?)(\d+)$/

    version_suffix_contained_a_v = false

    match = name.match(version_suffix_regex)
    if match
      version_suffix_contained_a_v = match[1] && match[1] != ''
      version_suffix_digit = match[2].to_i
      increment = version_suffix_digit + 1 if increment < version_suffix_digit
    end

    name_stripped_of_suffix = name.sub(version_suffix_regex, '')

    maybe_v = version_suffix_contained_a_v ? 'v' : ''

    "#{name_stripped_of_suffix}-#{maybe_v}#{increment}"
  end

  private def propose_incremented_name_for(name, increment)

    version_suffix_regex = /-(v?)(\d+)$/

    version_suffix_contained_a_v = false

    match = name.match(version_suffix_regex)
    if match
      version_suffix_contained_a_v = match[1] && match[1] != ''
      version_suffix_digit = match[2].to_i
      increment = version_suffix_digit + 1 if increment < version_suffix_digit
    end

    name_stripped_of_suffix = name.sub(version_suffix_regex, '')

    maybe_v = version_suffix_contained_a_v ? 'v' : ''

    "#{name_stripped_of_suffix}-#{maybe_v}#{increment}"
  end
end
