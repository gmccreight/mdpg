class Tag < ModelBase

  attr_accessor :name, :page_ids, :user_ids

  private

    def unique_id_indexes
      [:name]
    end

end
