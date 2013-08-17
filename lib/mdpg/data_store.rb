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
    data
  end

  def set key, data
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
    set(key + "__deleted", get(key))

    if data_dir_or_memory == :memory
      @data.delete key
    else
      File.delete(full_path_for_key(key))
    end
  end

  private

    def get_in_memory_value key
      @data ||= {}
      @data[key]
    end

    def set_in_memory_value key, data
      @data ||= {}
      @data[key] = data
    end

    def full_path_for_key key
      data_dir_or_memory() + "/" + directory_for_key(key) + "/" + key
    end

    def directory_for_key key
      digest = digest_of_key key
      digest[0..1]
    end

    def digest_of_key key
      Digest::SHA1.hexdigest(key) #like git
    end

end
