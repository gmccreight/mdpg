# frozen_string_literal: true

class LabeledSectionTranscluder
  OPTS_REGEX_STR = '[a-z0-9-]+[a-z0-9,-]*'
  def get_page_ids(text)
    ids = []
    text.gsub(internal_link_regex) do
      page_id = Regexp.last_match(1).to_i
      ids << page_id
    end
    ids
  end

  def transclude_sections(text)
    text.gsub(internal_link_regex) do
      page_id = Regexp.last_match(1).to_i
      section_identifier = Regexp.last_match(2)
      opts = LabeledSectionParser.process_opts(Regexp.last_match(3))

      page = Page.find(page_id)

      parser = LabeledSectionParser.new(page.text)
      parser.process

      section_name = parser.name_for(section_identifier)

      yield page, parser, section_name, section_identifier, opts
    end
  end

  def link_text(str, opts)
    if !opts.empty?
      str = str + ':' + opts.join(',')
    end
    '[[' + str + ']]'
  end

  def user_facing_links_to_internal_links(text, user_pages)
    t = Token::TOKEN_REGEX_STR
    text = text.gsub(
      /\[\[(#{t})#(#{t})(:#{OPTS_REGEX_STR})?\]\]/
    ) do
      page_name = Regexp.last_match(1)
      section_name = Regexp.last_match(2)
      opts = LabeledSectionParser.process_opts(Regexp.last_match(3))

      result = ''

      if page_name == 'mdpgpage'
        result = link_text("#{page_name}:#{section_name}", opts)
      else
        page = user_pages.find_page_with_name(page_name)

        if page
          parser = parser_with_processed_text_for(page.text)
          id = parser.identifier_for(section_name)

          if id
            result = link_text("mdpgpage:#{page.id}:#{id}", opts)
          end
        end
      end

      if result == ''
        result = link_text("#{page_name}##{section_name}", opts)
      end

      result
    end

    text
  end

  def internal_links_to_user_facing_links(text)
    text = text.gsub(internal_link_regex) do
      page_id = Regexp.last_match(1).to_i
      section_id = Regexp.last_match(2)
      opts = LabeledSectionParser.process_opts(Regexp.last_match(3))

      result = ''

      page = Page.find(page_id)

      if page
        parser = parser_with_processed_text_for(page.text)
        section_name = parser.name_for(section_id)

        if section_name
          result = link_text("#{page.name}##{section_name}", opts)
        end
      end

      if result == ''
        result = link_text("mdpgpage:#{page_id}##{section_id}", opts)
      end

      result
    end

    text
  end

  def internal_link_data(text)
    result = []
    text.gsub(internal_link_regex) do
      page_id = Regexp.last_match(1).to_i
      sec_id = Regexp.last_match(2)
      opts = LabeledSectionParser.process_opts(Regexp.last_match(3))
      result << { page_id: page_id, section_id: sec_id, opts: opts }
    end

    result
  end

  private def parser_with_processed_text_for(text)
    parser = LabeledSectionParser.new(text)
    parser.process
    parser
  end

  private def internal_link_regex
    /\[\[mdpgpage:(\d+):(#{Token::TOKEN_REGEX_STR})(:#{OPTS_REGEX_STR})?\]\]/
  end
end
