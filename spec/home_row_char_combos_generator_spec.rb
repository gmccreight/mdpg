require_relative "./spec_helper"

require "home_row_char_combos_generator"

describe HomeRowCharCombosGenerator do

  before do
    @generator = HomeRowCharCombosGenerator.new()
  end

  it "should make unique homerow character combo sets" do
    total_possible_num_combos = 80
    char_combos = (1..total_possible_num_combos).
      map{@generator.next_char_combo(3)}.sort
    assert_equal "hah", char_combos.first
    assert_equal total_possible_num_combos, char_combos.uniq.size
  end

end
