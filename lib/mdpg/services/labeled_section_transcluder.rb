class LabeledSectionTranscluder

  def get_page_ids(user_pages, text)

    ids = []

    text.gsub(
      /\[\[mdpgpage:(\d+):#{Token::TOKEN_REGEX_STR}\]\]/
    ) do
      page_id = $1.to_i
      ids << page_id
    end

    ids

  end

  def transclude_the_sections text
    text.gsub(
      /\[\[mdpgpage:(\d+):(#{Token::TOKEN_REGEX_STR})\]\]/
    ) do
      page_id = $1.to_i
      section_identifier = $2

      page = Page.find(page_id)

      section = LabeledSections.new(Page.find(page_id).text)
      section.process

      section_name = section.name_for(section_identifier)

      "[[#{page.name}##{section_name}:start]]

      #{section.text_for(section_identifier)}

      [[#{page.name}##{section_name}:end]]".gsub(/^[ ]+/, '')
    end
  end

  def user_facing_links_to_internal_links text, user_pages
    text = text.gsub(
      /\[\[(#{Token::TOKEN_REGEX_STR})#(#{Token::TOKEN_REGEX_STR})\]\]/
    ) do
      page_name = $1
      section_name = $2

      result = ""

      if page_name == "mdpgpage"
        result = "[[#{page_name}:#{section_name}]]"
      else
        page = user_pages.find_page_with_name(page_name)

        if page
          sections = LabeledSections.new(page.text)
          sections.process
          identifier = sections.identifier_for(section_name)

          if identifier
            result = "[[mdpgpage:#{page.id}:#{identifier}]]"
          end
        end
      end

      if result == ""
        result = "[[#{page_name}##{section_name}]]"
      end

      result
    end

    text

  end

  def internal_links_to_user_facing_links text
    text = text.gsub(
      /\[\[mdpgpage:(\d+):(#{Token::TOKEN_REGEX_STR})\]\]/
    ) do
      page_id = $1.to_i
      section_id = $2

      result = ""

      page = Page.find(page_id)

      if page
        sections = LabeledSections.new(page.text)
        sections.process
        section_name = sections.name_for(section_id)

        if section_name
          result = "[[#{page.name}##{section_name}]]"
        end
      end

      if result == ""
        result = "[[mdpgpage:#{page_id}##{section_id}]]"
      end

      result
    end

    text

  end

end
