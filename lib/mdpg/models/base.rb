# frozen_string_literal: true

class ModelBase
  attr_accessor :data_store, :id, :revision_to_find

  def initialize
    @id = nil
    @data_store = $data_store
  end

  def self.create(opts = {})
    new.create(opts)
  end

  def self.find(id, revision = nil)
    new.find(id, revision)
  end

  def self.find_by_index(index_name, value)
    new.find_by_index(index_name, value)
  end

  def create(opts)
    @id = max_id + 1

    add_attributes_from_hash opts

    if save
      self.max_id = @id
      return self
    end
    nil
  end

  def find(id, revision = nil)
    self.id = id
    self.revision_to_find = revision if revision
    attrs = data_store.get(data_key)
    self.revision_to_find = nil
    return unless attrs

    load(attrs)
    self
  end

  def reload
    find(id)
  end

  def virtual_delete
    data_store.virtual_delete(data_key)
  end

  def find_by_index(index_name, key)
    keyname = "#{data_prefix}-index-#{index_name}"
    hash = data_store.get(keyname)
    if hash
      return find hash[key]
    else
      return nil
    end
  end

  def add_associated_object(object)
    alter_associated_object object, :add
  end

  def remove_associated_object(object)
    alter_associated_object object, :remove
  end

  def load(attrs)
    add_attributes_from_hash attrs
  end

  def save
    ensure_attr_defaults
    return unless validates?

    possibly_update_revision

    pre_existing_data = data_store.get data_key
    data_store.set data_key, persistable_data
    update_unique_id_indexes(pre_existing_data, persistable_data)
  end

  private def attr_defaults
    {}
  end

  private def ensure_attr_defaults
    attr_defaults.each_key do |key|
      ensure_attribute_with_default key, attr_defaults[key]
    end
  end

  private def ensure_attribute_with_default(attr_name, default_value)
    return if send(attr_name)

    default_value = default_value.call if default_value.class == Proc
    send "#{attr_name}=", default_value
  end

  private def possibly_update_revision
    return unless versioned?

    set_max_revision
    self.revision = max_revision
  end

  private def versioned?
    false
  end

  private def alter_associated_object(object, add_or_remove)
    type = type_name_for_object object
    ids = get_ids_for_association_of_type type
    if add_or_remove == :add
      ids += [object.id]
    elsif add_or_remove == :remove
      ids -= [object.id]
    end
    set_ids_for_association_of_type type, ids.sort.uniq
  end

  private def type_name_for_object(object)
    object.class.name.split('::').last.downcase
  end

  private def data_prefix
    type_name_for_object(self) + 'data'
  end

  private def get_var(name)
    instance_variable_get name
  end

  private def set_var(name, value)
    instance_variable_set name, value
  end

  private def get_ids_for_association_of_type(type)
    ids = get_var "@#{type}_ids"
    ids || []
  end

  private def set_ids_for_association_of_type(type, val)
    set_var("@#{type}_ids", val)
  end

  private def update_unique_id_indexes(pre_existing_data, new_data)
    unique_id_indexes.each do |attribute_symbol|
      next unless attribute_was_updated?(pre_existing_data, new_data,
                                         attribute_symbol)
      keyname = "#{data_prefix}-index-#{attribute_symbol}"
      hash = data_store.get(keyname) || {}
      value = get_var "@#{attribute_symbol}"
      remove_any_preexisting_unique_indexes hash
      hash[value] = id
      data_store.set(keyname, hash)
    end
  end

  private def attribute_was_updated?(pre_existing_data, new_data, attr)
    return true unless pre_existing_data
    return false if pre_existing_data[attr] == new_data[attr]
    true
  end

  private def remove_any_preexisting_unique_indexes(hash)
    hash.keys.each do |key|
      hash.delete(key) if hash[key] == id
    end
    hash
  end

  private def persistable_data
    h = {}
    persistable_attributes.each { |key| h[key] = get_var("@#{key}") }
    h
  end

  private def add_attributes_from_hash(opts)
    persistable_attributes.each do |key|
      next if key == :id
      val = opts.key?(key) ? opts[key] : nil
      set_var "@#{key}", val
    end
  end

  private def validates?
    true
  end

  private def max_id=(val)
    data_store.set("#{data_prefix}-max-id", val)
  end

  private def max_id
    data_store.get("#{data_prefix}-max-id") || 0
  end

  private def persistable_attributes
    @persistable_attributes ||= attributes.reject { |x| x == :data_store }
  end

  private def attributes
    self.class::ATTRS
  end

  private def max_revision
    data_store.get(revisionless_data_key + '-max-revision') || -1
  end

  private def set_max_revision
    rev = max_revision
    data_store.set(revisionless_data_key + '-max-revision', rev + 1)
  end

  private def data_key
    if versioned?
      rev = if revision_to_find
              revision_to_find
            else
              max_revision
            end

      revisionless_data_key + "-#{rev}"
    else
      revisionless_data_key
    end
  end

  private def revisionless_data_key
    "#{data_prefix}-#{id}"
  end

  private def unique_id_indexes
    []
  end
end
