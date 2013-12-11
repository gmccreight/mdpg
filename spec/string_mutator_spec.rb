require_relative "./spec_helper"

require "string_mutator"

describe StringMutator do

  def mutate_string string
    mutator = StringMutator.new(string)
    mutator.get_all_mutations()
  end

  it "should not replace ||= with &&=" do
    string = "value ||= 'default'"
    mutations = [
      "",
    ]
    assert_equal mutations, mutate_string(string)
  end

  it "should mutate both || to && and && to ||" do
    string = "hello || what && bye"
    mutations = [
      "",
      "hello || what || bye",
      "hello && what && bye"
    ]
    assert_equal mutations, mutate_string(string)
  end

  it "should have multiple mutations for the same replacement" do
    string = "hello && what && bye"
    mutations = [
      "",
      "hello || what && bye",
      "hello && what || bye"
    ]
    assert_equal mutations, mutate_string(string)
  end

  it "should mutate == to !=" do
    string = "if foo == bar"
    mutations = [
      "",
      "if foo != bar",
    ]
    assert_equal mutations, mutate_string(string)
  end

  it "should mutate != to ==" do
    string = "if foo != bar"
    mutations = [
      "",
      "if foo == bar",
    ]
    assert_equal mutations, mutate_string(string)
  end

end
