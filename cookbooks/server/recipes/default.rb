template "#{ENV['HOME']}/server.sh" do
  source "server.sh.erb"
  mode "0755"
end

execute "start server" do
  cwd ENV['HOME']
  command "./server.sh"
end
