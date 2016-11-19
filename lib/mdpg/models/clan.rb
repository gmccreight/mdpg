# frozen_string_literal: true

class Clan < ModelBase
  ATTRS = [:name, :admins, :members].freeze

  attr_accessor(*ATTRS)
end
