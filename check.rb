#!/usr/bin/env ruby

begin
  require 'ap'
rescue LoadError
  def ap(whatever)
    puts whatever.inspect
  end
end

require 'json'
require 'net/http'

load 'lib/bootswatch-sass/version.rb'

json = Net::HTTP.get(URI.parse('https://api.github.com/repos/thomaspark/bootswatch/tags'))
json = JSON.parse(json)
tag = json.select { |tag| tag['name'] =~ /^v\d+\.\d+\.\d+/ }.first

local_version = Gem::Version.new(BootswatchSass::VERSION)
remote_version_string = tag['name'].gsub(/^v/, '')
remote_version = Gem::Version.new(remote_version_string.gsub('+', '.'))

if local_version < remote_version
  puts "Local version #{local_version} is behind remote version #{remote_version_string} :-("
elsif local_version > remote_version
  puts "Local version #{local_version} is ahead of remote version #{remote_version_string} 0.o"
else
  puts "Local version #{local_version} is the same as remote version #{remote_version_string} :-)"
end
