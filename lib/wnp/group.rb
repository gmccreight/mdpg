require 'wnp/token'

module Wnp

  class Group < Struct.new(:env, :id, :name, :admins, :members)

    DATA_PREFIX = "groupdata"

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

      env.data.set data_filename(), self.to_h
      true
    end

    def validate_name
      Wnp::Token.new(name).validate
    end

    def load
      attrs = env.data.get(data_filename())

      # for some reason I can't seem to get these to work when looping through
      # the persistable_attributes... so I'm leaving them like this for now.
      self.name = attrs[:name]
      self.admins = attrs[:admins]
      self.members = attrs[:members]
    end

    private

      def data_filename
        "#{DATA_PREFIX}-#{id}"
      end

      def set_max_id(val)
        env.data.set("#{DATA_PREFIX}-max-id", val)
      end

      def get_max_id
        env.data.get("#{DATA_PREFIX}-max-id") || 0
      end

  end

end
