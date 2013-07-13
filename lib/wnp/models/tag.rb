module Wnp::Models

  class Tag < Base

    attr_accessor :name, :page_ids, :user_ids

    def add_page_id id
      self.page_ids = ((page_ids || []) + [id]).sort.uniq.sort
    end

    def remove_page_id id
      self.page_ids = ((page_ids || []) - [id]).sort.uniq.sort
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
