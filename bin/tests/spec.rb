#!/usr/bin/env ruby

# The point of using this script is that it runs about 0.2 seconds faster than
# running "rake"

$LOAD_PATH << 'spec'
$LOAD_PATH << 'lib'

files = Dir.glob('spec/**/*.rb')

files.reject! { |x| x =~ /sinatra/ } if ARGV[0] == 'f'

files.each { |file| require file.sub(/^spec\/|.rb$/, '') }
