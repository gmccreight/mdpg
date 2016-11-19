# frozen_string_literal: true

class Tag < ModelBase
  ATTRS = [:name, :page_ids, :user_ids].freeze

  attr_accessor(*ATTRS)

  private def unique_id_indexes
    [:name]
  end
end
