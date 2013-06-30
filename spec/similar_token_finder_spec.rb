require_relative "./spec_helper"

require "similar_token_finder"

describe SimilarTokenFinder do

  def get_similar_tokens query, tokens
    SimilarTokenFinder.new.get_similar_tokens(query, tokens)
  end

  it "should fuzzy match tokens, returning best matches first" do
    assert_equal ["tomfoolery", "foo", "fool"], get_similar_tokens("foo", ["foo", "john", "tofu", "fool", "ford", "work", "tomfoolery"])
  end

  it "should match with hyphens, too" do
    assert_equal ["my-cool-pagename", "anotherpagename"], get_similar_tokens("mycoolpagename", ["my-cool-pagename", "some-other-thing", "anotherpagename"])
  end

end
