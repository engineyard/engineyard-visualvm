# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "engineyard-visualvm"
  s.version = "0.5.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Nick Sieger"]
  s.date = "2012-01-31"
  s.description = "This provides a Java agent and command-line utility to enable\n    JMX in any Java process such that it can be accessed through a firewall,\n    and a VisualVM launcher aid to connect to that process through ssh."
  s.email = ["nick@nicksieger.com"]
  s.executables = ["ey-visualvm"]
  s.files = [".gitignore", "ChangeLog", "Gemfile", "LICENSE.txt", "README.md", "Rakefile", "Vagrantfile", "bin/ey-visualvm", "cookbooks/apt/README.md", "cookbooks/apt/files/default/apt-cacher", "cookbooks/apt/files/default/apt-cacher.conf", "cookbooks/apt/files/default/apt-proxy-v2.conf", "cookbooks/apt/metadata.json", "cookbooks/apt/metadata.rb", "cookbooks/apt/providers/repository.rb", "cookbooks/apt/recipes/cacher-client.rb", "cookbooks/apt/recipes/cacher.rb", "cookbooks/apt/recipes/default.rb", "cookbooks/apt/resources/repository.rb", "cookbooks/gems/recipes/default.rb", "cookbooks/java/README.md", "cookbooks/java/attributes/default.rb", "cookbooks/java/files/default/java.seed", "cookbooks/java/metadata.json", "cookbooks/java/metadata.rb", "cookbooks/java/recipes/default.rb", "cookbooks/java/recipes/openjdk.rb", "cookbooks/java/recipes/sun.rb", "cookbooks/jruby/attributes/default.rb", "cookbooks/jruby/recipes/default.rb", "cookbooks/server/recipes/default.rb", "cookbooks/server/templates/default/server.sh.erb", "cookbooks/vagrant_main/recipes/default.rb", "engineyard-visualvm-java.gemspec", "engineyard-visualvm.gemspec", "engineyard-visualvm.gemspec.in", "ext/org/jruby/ext/jmx/Agent.java", "ext/org/jruby/ext/jmx/JavaHome.java", "ext/org/jruby/ext/jmx/RMIServerSocketFactoryImpl.java", "lib/engineyard-visualvm.rb", "lib/engineyard-visualvm/agent.jar", "lib/engineyard-visualvm/cli.rb", "lib/engineyard-visualvm/version.rb", "spec/engineyard-visualvm_spec.rb", "spec/spec_helper.rb"]
  s.homepage = "https://github.com/engineyard/engineyard-visualvm"
  s.require_paths = ["lib"]
  s.rubyforge_project = "jruby-extras"
  s.rubygems_version = "1.8.15"
  s.summary = "Client and server helpers for using JMX and VisualVM with EY Cloud."
  s.test_files = ["spec/engineyard-visualvm_spec.rb", "spec/spec_helper.rb"]

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<childprocess>, [">= 0"])
      s.add_runtime_dependency(%q<engineyard>, [">= 0"])
      s.add_runtime_dependency(%q<ffi-ncurses>, [">= 0"])
      s.add_development_dependency(%q<rspec>, [">= 0"])
    else
      s.add_dependency(%q<childprocess>, [">= 0"])
      s.add_dependency(%q<engineyard>, [">= 0"])
      s.add_dependency(%q<ffi-ncurses>, [">= 0"])
      s.add_dependency(%q<rspec>, [">= 0"])
    end
  else
    s.add_dependency(%q<childprocess>, [">= 0"])
    s.add_dependency(%q<engineyard>, [">= 0"])
    s.add_dependency(%q<ffi-ncurses>, [">= 0"])
    s.add_dependency(%q<rspec>, [">= 0"])
  end
end
