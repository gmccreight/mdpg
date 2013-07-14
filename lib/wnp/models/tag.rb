module Wnp::Models

  class Tag < Base

    attr_accessor :name, :page_ids, :user_ids

    private

      def unique_id_indexes
        [:name]
      end

      def validates?
      end

  end

end
