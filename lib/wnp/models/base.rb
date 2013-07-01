module Wnp::Models

  class Base

    attr_accessor :data_store, :id

    def initialize
      @id = nil
      @data_store = $data_store
    end

    def self.create opts = {}
      self.new().create(opts)
    end

    def self.find id
      self.new().find(id)
    end

    def self.find_by_index index_name, value
      self.new().find_by_index(index_name, value)
    end

    def create opts
      @id = get_max_id() + 1

      add_attributes_from_hash opts

      if save
        set_max_id @id
        return self
      end
      nil
    end

    def find id
      self.id = id
      if attrs = data_store.get(data_key)
        self.load(attrs)
        self
      else
        nil
      end
    end

    def find_by_index index_name, key
      keyname = "#{get_data_prefix}-index-#{index_name}"
      if hash = data_store.get(keyname)
        if hash.has_key?(key)
          return find hash[key]
        else
          return nil
        end
      else
        return nil
      end

      self.new().find_by_index(index_name, value)
    end

    def load attrs
      add_attributes_from_hash attrs
    end

    def save
      data_store.set data_key, persistable_data
      update_unique_id_indexes()
    end

    private

      def update_unique_id_indexes
        unique_id_indexes.each do |attribute_symbol|
          keyname = "#{get_data_prefix}-index-#{attribute_symbol}"
          hash = data_store.get(keyname) || {}
          value = instance_variable_get "@#{attribute_symbol}"
          hash[value] = self.id
          data_store.set(keyname, hash)
        end
      end

      def persistable_data
        h = {}
        persistable_attributes.each{|key| h[key] = instance_variable_get("@#{key}")}
        h
      end

      def add_attributes_from_hash(opts)
        persistable_attributes.each do |key|
          next if key == :id
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
        data_store.set("#{get_data_prefix()}-max-id", val)
      end

      def get_max_id
        data_store.get("#{get_data_prefix()}-max-id") || 0
      end

      def persistable_attributes
        attributes.reject{|x| x == :data_store}
      end

      def attributes
        self.class.instance_methods.find_all do |method|
          method != :== &&
          method != :! &&
          self.class.instance_methods.include?(:"#{method}=")
        end
      end

      def data_key
        "#{get_data_prefix}-#{id}"
      end

      def get_data_prefix
        raise NotImplementedError
      end

      def unique_id_indexes
        []
      end

  end

end
