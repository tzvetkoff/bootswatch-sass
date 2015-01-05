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

json = Net::HTTP.get(URI.parse('http://api.bootswatch.com/3/'))
json = JSON.parse(json)

local_version = Gem::Version.new(BootswatchSass::VERSION)
remote_version = Gem::Version.new(json['version'].gsub('+', '.'))

if local_version < remote_version
  puts "Local version #{local_version} is behind remote version #{json['version']} :-("
elsif local_version > remote_version
  puts "Local version #{local_version} is ahead of remote version #{json['version']} 0.o"
else
  puts "Local version #{local_version} is the same as remote version #{json['version']} :-)"
end
