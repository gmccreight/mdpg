# frozen_string_literal: true

class Token < Struct.new(:text)
  TOKEN_REGEX_STR = '[a-z0-9-]+'
  TOKEN_MIN_LENGTH = 3
  TOKEN_MAX_LENGTH = 64

  def validate
    return :blank if !text || text.empty?
    return :too_short if text.size < TOKEN_MIN_LENGTH
    return :too_long if text.size > TOKEN_MAX_LENGTH
    return :only_a_z_0_9_and_hyphens_ok if text !~ /^#{TOKEN_REGEX_STR}$/
    nil
  end
end
