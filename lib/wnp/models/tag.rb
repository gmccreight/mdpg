module Wnp::Models

  class Tag < Base

    attr_accessor :name, :page_ids, :user_ids

    def type_name
      "tag"
    end

    private

      def unique_id_indexes
        [:name]
      end

      def validates?
      end

      def get_data_prefix
        "tagdata"
      end

  end

end
