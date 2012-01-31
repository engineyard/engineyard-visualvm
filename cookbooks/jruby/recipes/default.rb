#--
# Copyright (c) 2011-2012 Engine Yard, Inc.
# See the file LICENSE.txt included with the distribution for
# software license details.
#++

include_recipe "java"

version = node[:jruby][:version]

remote_file "/usr/src/jruby-bin-#{version}.tar.gz" do
  source "http://jruby.org.s3.amazonaws.com/downloads/#{version}/jruby-bin-#{version}.tar.gz"
  checksum node[:jruby][:checksum]
end

execute "untar jruby" do
  command "tar xzf /usr/src/jruby-bin-#{version}.tar.gz "
  cwd "/usr/local/lib"
  creates "/usr/local/lib/jruby-#{version}"
end

link "/usr/local/jruby" do
  to "/usr/local/lib/jruby-#{version}"
end

%w( jruby jirb jgem ).each do |b|
  link "/usr/local/bin/#{b}" do
    to "/usr/local/jruby/bin/#{b}"
  end
end
