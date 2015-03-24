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
    result = "#{name}-#{increment}"
    while user_pages.find_page_with_name(result)
      increment += 1
      result = "#{name}-#{increment}"
    end
    return result
  end

end
