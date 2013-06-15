module Wnp

  class Token < Struct.new(:text)

    def validate
      return :blank if ! text || text.empty?
      return :too_short if text.size < 3
      return :too_long if text.size > 60
      if text !~ /^[a-z0-9-]+$/
        return :only_a_z_0_9_and_hyphens_ok
      end
      nil
    end

  end

end
