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
    result = []
    @partials_count_for.keys.each do |partial_name|
      if @partials_count_for[partial_name] != 2 ||
          ! @partials_status_for.has_key?(partial_name) ||
          @partials_status_for[partial_name] != "closed"
        result << partial_name
      end
    end
    result
  end

  def list
    result = []
    @partials_status_for.keys.each do |partial_name|
      if @partials_status_for[partial_name] == "closed"
        result << partial_name
      end
    end
    result
  end

  private def reset
    @partials_count_for = {}
    @partials_count_for.default = 0

    @partials_status_for = {}
  end

  private def process_text text

    text.gsub(partial_regex) do
      partial_name = $1
      start_or_end = $2

      @partials_count_for[partial_name] += 1

      if start_or_end == "start"
        if ! @partials_status_for.has_key?(partial_name)
          @partials_status_for[partial_name] = "opened"
        end
      elsif start_or_end == "end"
        if @partials_status_for[partial_name] = "opened"
          @partials_status_for[partial_name] = "closed"
        end
      end
    end

  end

  private def partial_regex
    %r{\[\[:partial:(#{Token::TOKEN_REGEX_STR}):(start|end)\]\]}
  end

end
