class Partial < Struct.new(:start_char, :end_char, :name, :identifier, :count)

end

class PagePartials

  def initialize(text)
    @text = text
    reset
  end

  def process
    reset
    process_text @text
  end

  def identifier_for partial_name
    return nil if had_error?
    partial = partial_with_name_or_identifier(partial_name, partial_name)
    partial.identifier
  end

  def name_for partial_id
    return nil if had_error?
    partial = partial_with_name_or_identifier(partial_id, partial_id)
    partial.name
  end

  def add_any_missing_identifiers
    return @text if ! has_any_partial_definitions?

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
    @text.gsub(partial_regex(remove_space:false)) do
      name = $1
      yield name
    end
  end

  def had_error?
    partial_names_with_errors.size > 0
  end

  def partial_names_with_errors
    @partials.select{|x| x.count != 2 || x.end_char == nil}.map{|x| x.name}
  end

  def list
    @partials.map{|x| x.name}
  end

  def text_for partial_name
    return nil if had_error?
    partial = partial_with_name_or_identifier(partial_name, partial_name)
    internal_text = @text[partial.start_char..partial.end_char].strip
    internal_text.gsub(partial_regex(remove_space:true), "")
  end

  private def has_any_partial_definitions?
    @text.match(partial_regex(remove_space:false))
  end

  private def any_missing_identifiers?
    @partials.map{|x| x.identifier}
  end

  private def partial_with_name_or_identifier name, identifier
    array = @partials.
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
    @partials = []
  end

  private def process_text text

    text.gsub(partial_regex(remove_space:false)).with_index do |m, i|

      name = $1
      identifier = $2

      if identifier
        identifier = identifier[1..-1]
      end

      partial = partial_with_name_or_identifier(name, identifier)

      if partial
        if partial.count == 1
          offset = Regexp.last_match.offset(0)[0] - 1
          partial.end_char = offset
        end
        partial.count += 1
      else
        offset = Regexp.last_match.offset(0)[1]
        @partials << Partial.new(offset, nil, name, identifier, 1)
      end

    end

  end

  private def partial_regex remove_space:
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
