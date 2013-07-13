module Wnp::Models

  class Tag < Base

    attr_accessor :name

    private

      def validates?
      end

      def get_data_prefix
        "tagdata"
      end

  end

end
