class UserPageDuplicator < Struct.new(:user_pages, :user, :original_page)

  def duplicate
    new_page_name = new_name(original_page.name)
    new_page = user_pages.create_page({:name => new_page_name})
    new_page.text = original_page.text

    user_page_tags = UserPageTags.new(user, original_page)
    user_page_tags.duplicate_tags_to_other_page(new_page)

    new_page.save()
    return new_page
  end

  private def new_name(name)
    increment = 2
    result = propose_name_for(name, increment)
    while user_pages.find_page_with_name(result)
      increment += 1
      result = propose_name_for(name, increment)
    end
    return result
  end

  private def propose_name_for(name, increment)
    regex = %r{-(v?)(\d+)$}

    had_a_v = false

    if match = name.match(regex)
      had_a_v = match[1] && match[1] != ""
      digit = match[2].to_i
      if increment < digit
        increment = digit + 1
      end
    end

    name_stripped = name.sub(regex, "")

    maybe_v = had_a_v ? "v" : ""
    "#{name_stripped}-#{maybe_v}#{increment}"
  end

end
