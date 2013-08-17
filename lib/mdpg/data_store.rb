require 'digest'
require 'yaml'
require 'fileutils'

class DataStore < Struct.new(:data_dir_or_memory)

  def get key
    if data_dir_or_memory == :memory
      data = get_in_memory_value(key)
    else
      data = nil
      filename = full_path_for_key key
      if File.exists? filename
        File.open(filename) do |file|
          data = YAML.load(file.read)
        end
      end
    end
    remove_datakey data
    data
  end

  def set key, data
    add_datakey_for_easy_file_searching data, key
    if data_dir_or_memory == :memory
      set_in_memory_value(key, data)
    else
      FileUtils.mkdir_p(data_dir_or_memory() + "/" + directory_for_key(key))
      File.open(full_path_for_key(key), 'w') do |file|
        file.write YAML.dump(data)
      end
    end
  end

  def virtual_delete key
    deleted_suffix = "__deleted"
    if data_dir_or_memory == :memory
      val = @data[key]
      @data[key + deleted_suffix] = val
      @data.delete key
    else
      deleted_path = full_path_for_key(key) + deleted_suffix
      FileUtils.mv(full_path_for_key(key), deleted_path)
    end
  end

  private

    def add_datakey_for_easy_file_searching data, key
      datakey_value = "_datakey_#{key}"

      if data.class == Hash
        data[:_datakey] = datakey_value
      elsif data.class == Array
        data.push datakey_value
      end

    end

    def remove_datakey data
      if data.class == Hash
        data.delete :_datakey
      elsif data.class == Array
        data.pop
      end
    end

    def get_in_memory_value key
      @data ||= {}
      @data[key]
    end

    def set_in_memory_value key, data
      @data ||= {}
      @data[key] = data
    end

    def full_path_for_key key
      data_dir_or_memory() + "/" + directory_for_key(key) + "/" +
        filename_for_key(key)
    end

    def directory_for_key key
      digest = digest_of_key key
      digest[0..1]
    end

    def filename_for_key key
      digest = digest_of_key key
      digest[2..-1]
    end

    def digest_of_key key
      Digest::SHA1.hexdigest(key) #like git
    end

end
