#--
# Copyright (c) 2011-2012 Engine Yard, Inc.
# See the file LICENSE.txt included with the distribution for
# software license details.
#++

template "#{ENV['HOME']}/server.sh" do
  source "server.sh.erb"
  mode "0755"
end

execute "start server" do
  cwd ENV['HOME']
  command "./server.sh"
end
