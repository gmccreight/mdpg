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

  def identifier_for section_name
    return nil if had_error?
    section = section_with_name_or_identifier(section_name, section_name)
    section.identifier
  end

  def name_for section_id
    return nil if had_error?
    section = section_with_name_or_identifier(section_id, section_id)
    section.name
  end

  def add_any_missing_identifiers
    return @text if ! has_any_section_definitions?

    process

    return @text if had_error?
    return @text if ! any_missing_identifiers?

    text = @text
    list.each do |name|
      identifier = get_new_identifier
      text = text.gsub(
        "[[##{name}]]",
        "[[##{name}:#{identifier}]]"
      )
    end

    text

  end

  def replace_definitions_with
    @text.gsub(section_regex(remove_space:false)) do
      name = $1
      yield name
    end
  end

  def had_error?
    section_names_with_errors.size > 0
  end

  def section_names_with_errors
    @sections.select{|x| x.count != 2 || x.end_char == nil}.map{|x| x.name}
  end

  def list
    @sections.map{|x| x.name}
  end

  def text_for section_name
    return nil if had_error?
    section = section_with_name_or_identifier(section_name, section_name)
    internal_text = @text[section.start_char..section.end_char].strip
    internal_text.gsub(section_regex(remove_space:true), '')
  end

  private def has_any_section_definitions?
    @text.match(section_regex(remove_space:false))
  end

  private def any_missing_identifiers?
    @sections.map{|x| x.identifier}
  end

  private def section_with_name_or_identifier name, identifier
    array = @sections.
      select{|x|
        x.name == name ||
          (x.identifier == identifier && identifier != nil)
      }

    return nil if ! array
    array.first
  end

  private def get_new_identifier
    RandStringGenerator.rand_string_of_length(32)
  end

  private def reset
    @sections = []
  end

  private def process_text text

    text.gsub(section_regex(remove_space:false)).with_index do

      name = $1
      identifier = $2

      if identifier
        identifier = identifier[1..-1]
      end

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

  private def section_regex remove_space:
    internal = "
      \\[\\[
      [#](#{Token::TOKEN_REGEX_STR})
      (:#{Token::TOKEN_REGEX_STR})?
      \\]\\]
    "
    if remove_space
      %r{\s?#{internal}\s?}x
    else
      %r{#{internal}}x
    end

  end

end
