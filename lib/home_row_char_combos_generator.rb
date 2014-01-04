class HomeRowCharCombosGenerator

  def initialize
    @_combos = {}
  end

  def next_char_combo length
    while true
      chars = _rand_right_left_repeat_combo length
      if ! @_combos.has_key?(chars)
        @_combos[chars] = true
        return chars
      end
    end
  end

  private

    def _rand_right_left_repeat_combo length
      right_chars = %w{h j k l}
      left_chars = %w{a s d f g}

      chars = ""
      (1..length).to_a.each do |x|
        if x % 2 == 1
          chars << right_chars.sample()
        else
          chars << left_chars.sample()
        end
      end

      chars
    end

end
