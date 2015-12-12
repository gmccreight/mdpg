require 'yaml'

class DataStore < Struct.new(:data_dir_or_memory)
  def initialize(data_dir_or_memory, lru_gc_size_threshold: 1000)
    @lru_gc_size_threshold = lru_gc_size_threshold
    reset_reporting_data
    super(data_dir_or_memory)
  end

  def reset_reporting_data
    @gets = {}
    @sets = {}
    @disk_gets = {}
    @disk_sets = {}
    @gets.default = 0
    @sets.default = 0
    @disk_gets.default = 0
    @disk_sets.default = 0
  end

  def get(key)
    @gets[key] += 1
    if data_dir_or_memory == :memory
      data = get_in_memory_value(key)
    else
      data = get_in_memory_value(key)
      unless data
        filename = full_path_for_key key
        if File.exist? filename
          @disk_gets[key] += 1
          File.open(filename) do |file|
            data = YAML.load(file.read)
          end
          set_in_memory_value(key, data)
        end
      end
    end
    data
  end

  def set(key, data)
    @sets[key] += 1
    if data_dir_or_memory == :memory
      set_in_memory_value(key, data)
    else
      set_in_memory_value(key, data)
      FileUtils.mkdir_p(data_dir_or_memory + '/' + directory_for_key(key))
      @disk_sets[key] += 1
      File.open(full_path_for_key(key), 'w') do |file|
        file.write YAML.dump(data)
      end
    end
  end

  def virtual_delete(key)
    set(key + '__deleted', get(key))

    if data_dir_or_memory == :memory
      @data.delete key
    else
      @data.delete key
      File.delete(full_path_for_key(key))
    end
  end

  def report
    { gets: @gets.sort_by { |_, v| v }.reverse,
      sets: @sets.sort_by { |_, v| v }.reverse,
      disk_gets: @disk_gets.sort_by { |_, v| v }.reverse,
      disk_sets: @disk_sets.sort_by { |_, v| v }.reverse
    }
  end

  def data_in_memory
    @data
  end

  private def get_in_memory_value(key)
    @data ||= {}
    @data[key]
  end

  private def set_in_memory_value(key, data)
    @data ||= {}
    @data[key] = data
    garbage_collect_lru_in_memory_data if data_dir_or_memory != :memory
  end

  private def garbage_collect_lru_in_memory_data
    return if @data.size <= @lru_gc_size_threshold
    @data.delete(@data.first[0])
  end

  private def full_path_for_key(key)
    data_dir_or_memory + '/' + directory_for_key(key) + '/' + key
  end

  private def directory_for_key(key)
    digest = digest_of_key key
    digest[0..1]
  end

  private def digest_of_key(key)
    Digest::SHA1.hexdigest(key) # like git
  end
end
