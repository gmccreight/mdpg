require 'wnp/modules/incrementing_id'
include Wnp::Modules::IncrementingId

module Wnp

  class Group < Struct.new(:env, :id, :name, :admins, :members)

    def create(name)
      new_group_id = get_max_id() + 1
      new_group = Group.new(env, new_group_id, name, [env.user.id], [env.user.id])
      if new_group.save()
        set_max_id(new_group_id)
        env.user.add_group(new_group_id)
      end
    end

    def save
      if error = validate_name()
        return false
      end

      env.data.set data_key, self.to_h
      true
    end

    def validate_name
      Wnp::Token.new(name).validate
    end

    def load
      attrs = env.data.get(data_key)

      # for some reason I can't seem to get these to work when looping through
      # the persistable_attributes... so I'm leaving them like this for now.
      self.name = attrs[:name]
      self.admins = attrs[:admins]
      self.members = attrs[:members]
    end

    private

      def data_key
        "#{get_data_prefix()}-#{id}"
      end

      def get_data_prefix
        "groupdata"
      end

  end

end
