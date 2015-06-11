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

  def partial_with_name_or_identifier name, identifier
    array = @partials.
      select{|x|
        x.name == name ||
          (x.identifier == identifier && identifier != nil)
      }

    return nil if ! array
    array.first
  end

  private def reset
    @partials = []
  end

  private def process_text text

    text.gsub(partial_regex(remove_space:false)).with_index do |m, i|

      name = $1
      start_or_end = $2
      identifier = $3

      if identifier
        identifier = identifier[1..-1]
      end

      partial = partial_with_name_or_identifier(name, identifier)

      if start_or_end == "start"
        if ! partial
          offset = Regexp.last_match.offset(0)[1]
          @partials << Partial.new(offset, nil, name, identifier, 1)
        else
          partial.count += 1
        end
      elsif start_or_end == "end"
        partial.count += 1
        offset = Regexp.last_match.offset(0)[0] - 1
        partial.end_char = offset
      end

    end

  end

  private def partial_regex remove_space:
    internal = "
      \\[\\[
      :partial
      :(#{Token::TOKEN_REGEX_STR})
      :(start|end)
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
