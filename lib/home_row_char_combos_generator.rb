class HomeRowCharCombosGenerator

  def initialize
    @_already_generated_combos = {}
  end

  def next_uniq_char_combo(length:)
    while true
      chars = _rand_right_left_right_left_repeat_char_combo length:length
      if ! @_already_generated_combos.has_key?(chars)
        @_already_generated_combos[chars] = true
        return chars
      end
    end
  end

  private

    def _rand_right_left_right_left_repeat_char_combo(length:)
      keys = [%w{a s d f g}, %w{h j k l}]

      chars = ""
      (1..length).each do |x|
        chars << keys[(x % 2)].sample()
      end

      chars
    end

end
