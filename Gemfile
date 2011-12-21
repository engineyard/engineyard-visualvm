#--
# Copyright (c) 2011 Engine Yard, Inc.
# See the file LICENSE.txt included with the distribution for
# software license details.
#++

source "http://rubygems.org"

group :development do
  gem "vagrant"
  gem "chef"

  gem "jmx", :platform => :jruby
end

gemspec_in = Dir['*.gemspec.in'].first
gemspec_ruby = gemspec_in.sub(/\.gemspec\.in/, '')
gemspec_java = gemspec_ruby + '-java'

platforms :jruby do
  gemspec :name => gemspec_java
end

platforms :ruby do
  gemspec :name => gemspec_ruby
end
