#!/usr/bin/env ruby

$:<<'spec'
$:<<'lib'
files = Dir.glob('spec/**/*.rb')
files.each{|file| require file.sub(/^spec\/|.rb$/,'')}
