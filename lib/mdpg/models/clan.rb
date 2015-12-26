# frozen_string_literal: true

class Clan < ModelBase
  ATTRS = [:name, :admins, :members]

  attr_accessor(*ATTRS)
end
