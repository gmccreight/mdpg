require 'yaml'

class DataStore < Struct.new(:data_dir_or_memory)

  def initialize(data_dir_or_memory)
    @disk_gets = []
    @disk_sets = []
    super(data_dir_or_memory)
  end

  def get key
    if data_dir_or_memory == :memory
      data = get_in_memory_value(key)
    else
      data = get_in_memory_value(key)
      if ! data
        filename = full_path_for_key key
        if File.exists? filename
          @disk_gets << key
          File.open(filename) do |file|
            data = YAML.load(file.read)
          end
          set_in_memory_value(key, data)
        end
      end
    end
    data
  end

  def set key, data
    if data_dir_or_memory == :memory
      set_in_memory_value(key, data)
    else
      set_in_memory_value(key, data)
      FileUtils.mkdir_p(data_dir_or_memory() + "/" + directory_for_key(key))
      @disk_sets << key
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
      @data.delete key
      File.delete(full_path_for_key(key))
    end
  end

  def report
    { disk_gets: @disk_gets, disk_sets: @disk_sets }
  end

  private def get_in_memory_value key
    @data ||= {}
    @data[key]
  end

  private def set_in_memory_value key, data
    @data ||= {}
    @data[key] = data
  end

  private def full_path_for_key key
    data_dir_or_memory() + "/" + directory_for_key(key) + "/" + key
  end

  private def directory_for_key key
    digest = digest_of_key key
    digest[0..1]
  end

  private def digest_of_key key
    Digest::SHA1.hexdigest(key) #like git
  end

end
