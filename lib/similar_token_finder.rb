# frozen_string_literal: true

require 'align/smith_waterman'

class SimilarTokenFinder
  def get_similar_tokens(query, tokens)
    tokens
      .map { |token| with_matchingness(query, token) }
      .sort { |a, b| a[1] <=> b[1] }
      .reverse
      .select { |x| x[1] > 4 }
      .map { |x| x[0] }
  end

  private def with_matchingness(w_1, w_2)
    [w_2, Align::SmithWaterman.new(w_1, w_2).max_score]
  end
end
