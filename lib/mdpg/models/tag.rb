class Tag < ModelBase
  ATTRS = [:name, :page_ids, :user_ids]

  attr_accessor(*ATTRS)

  private def unique_id_indexes
    [:name]
  end
end
