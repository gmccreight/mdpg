if ENV['perf']

  require_relative '../spec_helper'

  require 'tmpdir'

  describe 'Perfomance' do
    describe 'get and set' do
      before do
        @temp_dir = Dir.mktmpdir
        @data = DataStore.new @temp_dir
      end

      after do
        FileUtils.remove_entry @temp_dir
      end

      it 'should persist and retrieve a large array quickly' do
        array_length = 10_000
        @data.set 'somekey', (1..array_length).to_a
        array2 = @data.get 'somekey'
        assert_equal array_length, array2.length
      end

      it 'should persist and retrieve a large hash quickly' do
        hash_length = 10_000
        hash = {}
        (1..hash_length).to_a.each do |key|
          hash[key.to_s.to_sym] = 'hello'
        end
        @data.set 'somekey', hash
        hash2 = @data.get 'somekey'
        assert_equal hash_length, hash2.length
        assert_equal 'hello', hash2['3'.to_sym]
      end
    end
  end

end
