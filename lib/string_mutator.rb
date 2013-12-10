require "minitest/autorun"

class StringMutator

  def initialize line
    @line = line
  end

  def get_all_mutations
    results = []
    [
      MutationStrategyDeleteLine.new(@line),
      MutationStrategySwithAndForOr.new(@line),
      MutationStrategySwitchOrForAnd.new(@line)
    ].each do |mutation_strategy|
      results << mutation_strategy.get_mutations()
    end
    results.flatten
  end

end

class MutationStrategyBase

  def initialize line
    @line = line
  end

  def get_mutations
    results = []
    occurrence = 0
    while result = search_replace_occurrence_in_data(@line, _search(), _replace(), occurrence) do
      modified_string = result[0]
      occurrence_existed = result[1]
      break if !occurrence_existed
      results << modified_string
      occurrence += 1
    end
    results
  end

  def search_replace_occurrence_in_data data, search, replace, occurrence

    occurrence_existed = false
    index = -1

    data = data.gsub(search) { |match|
      index += 1
      if index == occurrence
        occurrence_existed = true
        replace
      else
        match
      end
    }
    [data, occurrence_existed]

  end

end

class MutationStrategyDeleteLine < MutationStrategyBase

  def _search
    %r{.+}
  end

  def _replace
    ""
  end

  def _do_multiple?
    false
  end

end

class MutationStrategySwithAndForOr < MutationStrategyBase

  def _search
    %r{&&}
  end

  def _replace
    "||"
  end

  def _do_multiple?
    true
  end

end

class MutationStrategySwitchOrForAnd < MutationStrategyBase

  def _search
    %r{\|\|}
  end

  def _replace
    "&&"
  end

  def _do_multiple?
    true
  end

end
