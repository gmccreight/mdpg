class Partial < Struct.new(:start_char, :end_char, :name, :identifier, :count)

end

class PagePartials

  def initialize
    reset
  end

  def process text
    reset
    process_text text
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

  private def reset
    @partials = []
  end

  private def process_text text

    text.gsub(partial_regex) do

      name = $1
      start_or_end = $2
      identifier = $3

      if identifier
        identifier = identifier[1..-1]
      end

      partial = @partials.
        select{|x|
          x.name == name || (x.identifier == identifier && identifier != nil)
        }.first

      if start_or_end == "start"
        if ! partial
          @partials << Partial.new(0, nil, name, identifier, 1)
        else
          partial.count += 1
        end
      elsif start_or_end == "end"
        partial.count += 1
        partial.end_char = 10
      end

    end

  end

  private def partial_regex
    %r{\[\[:partial:(#{Token::TOKEN_REGEX_STR}):(start|end)(:#{Token::TOKEN_REGEX_STR})?\]\]}
  end

end
