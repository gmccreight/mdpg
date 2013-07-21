require_relative "./spec_helper"

require "similar_token_finder"

describe SimilarTokenFinder do

  def get_similar_tokens query, tokens
    SimilarTokenFinder.new.get_similar_tokens(query, tokens)
  end

  it "should fuzzy match tokens, returning best matches first" do
    tokens = ["foo", "john", "tofu", "fool", "ford", "work", "tomfoolery"]
    assert_equal ["tomfoolery", "foo", "fool"],
      get_similar_tokens("foo", tokens)
  end

  it "should match with hyphens, too" do
    tokens = ["my-cool-pagename", "some-other-thing", "anotherpagename"]
    assert_equal ["my-cool-pagename", "anotherpagename"],
      get_similar_tokens("mycoolpagename", tokens)
  end

end
