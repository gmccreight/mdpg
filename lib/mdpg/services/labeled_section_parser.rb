# frozen_string_literal: true

class Section < Struct.new(:start_char, :end_char, :name, :identifier, :count)
end

class LabeledSectionParser
  def initialize(text)
    @text = text
    reset
  end

  def process
    reset
    process_text @text
  end

  def identifier_for(section_name)
    return nil if had_error?
    section = section_with_name_or_identifier(section_name, section_name)
    if section
      section.identifier
    end
  end

  def name_for(section_id)
    return nil if had_error?
    section = section_with_name_or_identifier(section_id, section_id)
    if section
      section.name
    else
      ''
    end
  end

  def add_any_missing_identifiers
    return @text unless any_section_definitions?

    process

    return @text if had_error?
    return @text unless any_missing_identifiers?

    text = @text
    list.each do |name|
      identifier = create_identifier
      text = text.gsub(
        "[[##{name}]]",
        "[[##{name}:#{identifier}]]"
      )
    end

    text
  end

  def replace_definitions_with
    @text.gsub(section_regex(remove_space: false)) do
      name = Regexp.last_match(1)
      yield name
    end
  end

  def had_error?
    !section_names_with_errors.empty?
  end

  def section_names_with_errors
    @sections.select { |x| x.count != 2 || x.end_char.nil? }.map(&:name)
  end

  def list
    @sections.map(&:name)
  end

  def text_for(section_name)
    return nil if had_error?
    section = section_with_name_or_identifier(section_name, section_name)
    if section
      internal_text = @text[section.start_char..section.end_char].strip
      internal_text.gsub(section_regex(remove_space: true), '')
    else
      ''
    end
  end

  private def any_section_definitions?
    @text.match(section_regex(remove_space: false))
  end

  private def any_missing_identifiers?
    @sections.map(&:identifier)
  end

  private def section_with_name_or_identifier(name, identifier)
    array = @sections
            .select do |x|
      x.name == name ||
        (x.identifier == identifier && !identifier.nil?)
    end

    return nil unless array
    array.first
  end

  private def create_identifier
    RandStringGenerator.rand_string_of_length(32)
  end

  private def reset
    @sections = []
  end

  private def process_text(text)
    text.gsub(section_regex(remove_space: false)).with_index do
      name = Regexp.last_match(1)
      identifier = Regexp.last_match(2)

      identifier = identifier[1..-1] if identifier

      section = section_with_name_or_identifier(name, identifier)

      if section
        if section.count == 1
          offset = Regexp.last_match.offset(0)[0] - 1
          section.end_char = offset
        end
        section.count += 1
      else
        offset = Regexp.last_match.offset(0)[1]
        @sections << Section.new(offset, nil, name, identifier, 1)
      end
    end
  end

  private def section_regex(remove_space:)
    internal = "
      \\[\\[
      [#](#{Token::TOKEN_REGEX_STR})
      (:#{Token::TOKEN_REGEX_STR})?
      \\]\\]
    "
    if remove_space
      /\s?#{internal}\s?/x
    else
      /#{internal}/x
    end
  end
end
