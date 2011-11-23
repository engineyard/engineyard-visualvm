GEMS = %w(jruby-openssl)

GEMS.each do |gem|
  gem_package gem do
    gem_binary "jgem"
    action :install
    version ">= 0"
  end
end

require '/vagrant/lib/engineyard-visualvm/version'
gem_package "/vagrant/pkg/engineyard-visualvm-#{EngineYard::VisualVM::VERSION}.gem" do
  gem_binary "jgem"
  action :install
  version ">= 0"
end
