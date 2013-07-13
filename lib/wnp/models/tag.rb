module Wnp::Models

  class Tag < Base

    attr_accessor :name, :type, :associated_ids

    private

      def validates?
      end

      def get_data_prefix
        "tagdata"
      end

  end

end
