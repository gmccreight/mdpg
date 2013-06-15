require 'digest'

module Wnp

  class Data < Struct.new(:data_dir)

    def get(key)
      data = nil
      filename = full_path_for_key key
      if File.exists? filename
        File.open(filename) do |file|
          data = Marshal.load(file)
        end
      end
      data
    end

    def set(key, data)
      FileUtils.mkdir_p(data_dir + "/" + directory_for_key(key))
      File.open(full_path_for_key(key), 'w') do |file|
        Marshal.dump(data, file)
      end
    end

    private

      def full_path_for_key(key)
        data_dir() + "/" + directory_for_key(key) + "/" + filename_for_key(key)
      end

      def directory_for_key(key)
        digest = digest_of_key key
        digest[0..1]
      end

      def filename_for_key(key)
        digest = digest_of_key key
        digest[2..-1]
      end

      def digest_of_key(key)
        Digest::SHA1.hexdigest(key) #like git
      end

  end

end
