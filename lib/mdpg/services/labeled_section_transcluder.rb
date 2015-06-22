class LabeledSectionTranscluder
  def get_page_ids(text)
    ids = []
    text.gsub(internal_link_regex) do
      page_id = Regexp.last_match(1).to_i
      ids << page_id
    end
    ids
  end

  def transclude_the_sections(text)
    text.gsub(internal_link_regex) do
      page_id = Regexp.last_match(1).to_i
      section_identifier = Regexp.last_match(2)

      page = Page.find(page_id)

      parser = LabeledSectionParser.new(Page.find(page_id).text)
      parser.process

      section_name = parser.name_for(section_identifier)

      yield page, parser, section_name, section_identifier
    end
  end

  def user_facing_links_to_internal_links(text, user_pages)
    text = text.gsub(
      /\[\[(#{Token::TOKEN_REGEX_STR})#(#{Token::TOKEN_REGEX_STR})\]\]/
    ) do
      page_name = Regexp.last_match(1)
      section_name = Regexp.last_match(2)

      result = ''

      if page_name == 'mdpgpage'
        result = "[[#{page_name}:#{section_name}]]"
      else
        page = user_pages.find_page_with_name(page_name)

        if page
          parser = parser_with_processed_text_for(page.text)
          identifier = parser.identifier_for(section_name)

          result = "[[mdpgpage:#{page.id}:#{identifier}]]" if identifier
        end
      end

      result = "[[#{page_name}##{section_name}]]" if result == ''

      result
    end

    text
  end

  def internal_links_to_user_facing_links(text)
    text = text.gsub(internal_link_regex) do
      page_id = Regexp.last_match(1).to_i
      section_id = Regexp.last_match(2)

      result = ''

      page = Page.find(page_id)

      if page
        parser = parser_with_processed_text_for(page.text)
        section_name = parser.name_for(section_id)

        result = "[[#{page.name}##{section_name}]]" if section_name
      end

      result = "[[mdpgpage:#{page_id}##{section_id}]]" if result == ''

      result
    end

    text
  end

  private def parser_with_processed_text_for(text)
    parser = LabeledSectionParser.new(text)
    parser.process
    parser
  end

  private def internal_link_regex
    /\[\[mdpgpage:(\d+):(#{Token::TOKEN_REGEX_STR})\]\]/
  end
end
