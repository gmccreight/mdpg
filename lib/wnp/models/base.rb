module Wnp::Models

  class Base

    attr_accessor :data, :id

    def initialize
      @id = nil
      @data = $data_store
    end

    def self.create opts = {}
      new_object = self.new()
      new_object.create(opts)
    end

    def create opts
      @id = get_max_id() + 1

      add_attributes_from_opts(opts)

      if save
        set_max_id @id
        return self
      end
      nil
    end

    def load
      attrs = env.data.get(data_key)
      after_load(attrs)
    end

    def save
      data.set data_key, persistable_data
    end

    private

      def persistable_data
        h = {}
        attributes.each{|key| h[key] = instance_variable_get("@#{key}")}
        h
      end

      def add_attributes_from_opts(opts)
        attributes.each do |key|
          next if key == :id || key == :data
          if opts.has_key?(key)
            instance_variable_set("@#{key}", opts[key])
          else
            instance_variable_set("@#{key}", nil)
          end
        end
      end

      def validates?
        true
      end

      def set_max_id val
        data.set("#{get_data_prefix()}-max-id", val)
      end

      def get_max_id
        data.get("#{get_data_prefix()}-max-id") || 0
      end

      def attributes
        self.class.instance_methods.find_all do |method|
          method != :== &&
          method != :! &&
          self.class.instance_methods.include?(:"#{method}=")
        end
      end

      def data_key
        raise NotImplementedError
      end

      def get_data_prefix
        raise NotImplementedError
      end

  end

end
