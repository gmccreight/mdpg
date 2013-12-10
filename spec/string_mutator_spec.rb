require_relative "./spec_helper"

require "string_mutator"

describe StringMutator do

  def mutate_string string
    mutator = StringMutator.new(string)
    mutator.get_all_mutations()
  end

  it "should mutate" do
    string = "hello && what && bye"
    mutations = [
      "",
      "hello || what && bye",
      "hello && what || bye"
    ]
    assert_equal mutations, mutate_string(string)
  end

end
