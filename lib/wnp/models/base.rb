module Wnp::Models

  class Base

    attr_accessor :data_store, :id

    def initialize
      @id = nil
      @errors = []
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

    def reload
      find(self.id)
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

    def add_associated_object object
      alter_associated_object object, :add
    end

    def remove_associated_object object
      alter_associated_object object, :remove
    end

    def load attrs
      add_attributes_from_hash attrs
    end

    def save
      if validates?
        possibly_update_revision()
        data_store.set data_key, persistable_data
        update_unique_id_indexes()
      end
    end

    private

      def possibly_update_revision
        if is_versioned?
          set_max_revision()
          self.revision = max_revision()
        end
      end

      def is_versioned?
        false
      end

      def alter_associated_object object, add_or_remove
        type = type_name_for_object object
        ids = get_ids_for_association_of_type type
        if add_or_remove == :add
          ids = ids + [object.id]
        elsif add_or_remove == :remove
          ids = ids - [object.id]
        end
        set_ids_for_association_of_type type, ids.sort.uniq
      end

      def type_name_for_object object
        object.class.name.split('::').last.downcase
      end

      def get_data_prefix
        type_name_for_object(self) + "data"
      end

      def get_var name
        instance_variable_get name
      end

      def set_var name, value
         instance_variable_set name, value
      end

      def get_ids_for_association_of_type type
        ids = get_var "@#{type}_ids"
        ids || []
      end

      def set_ids_for_association_of_type type, val
        set_var("@#{type}_ids", val)
      end

      def update_unique_id_indexes
        unique_id_indexes.each do |attribute_symbol|
          keyname = "#{get_data_prefix}-index-#{attribute_symbol}"
          hash = data_store.get(keyname) || {}
          value = get_var "@#{attribute_symbol}"
          hash[value] = self.id
          data_store.set(keyname, hash)
        end
      end

      def persistable_data
        h = {}
        persistable_attributes.each{|key| h[key] = get_var("@#{key}")}
        h
      end

      def add_attributes_from_hash(opts)
        persistable_attributes.each do |key|
          next if key == :id
          val = opts.has_key?(key) ? opts[key] : nil
          set_var "@#{key}", val
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
        @persistable_attributes ||= attributes.reject{|x| x == :data_store}
      end

      def attributes
        memoized_instance_methods.find_all do |method|
          method != :== &&
          method != :! &&
          memoized_instance_methods.include?(:"#{method}=")
        end
      end

      def memoized_instance_methods
        @instance_methods ||= self.class.instance_methods
      end

      def max_revision
        data_store.get(revisionless_data_key + "-max-revision") || -1
      end

      def set_max_revision
        rev = max_revision()
        data_store.set(revisionless_data_key + "-max-revision", rev + 1)
      end

      def data_key
        if is_versioned?
          rev = max_revision()
          revisionless_data_key() + "-#{rev}"
        else
          revisionless_data_key
        end
      end

      def revisionless_data_key
        "#{get_data_prefix}-#{id}"
      end

      def unique_id_indexes
        []
      end

  end

end
