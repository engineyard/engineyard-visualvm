# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{engineyard-visualvm}
  s.version = "0.5.3"
  s.platform = %q{java}

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = [%q{Nick Sieger}]
  s.date = %q{2011-12-21}
  s.description = %q{This provides a Java agent and command-line utility to enable
    JMX in any Java process such that it can be accessed through a firewall,
    and a VisualVM launcher aid to connect to that process through ssh.}
  s.email = [%q{nick@nicksieger.com}]
  s.executables = [%q{ey-visualvm}]
  s.files = [%q{.gitignore}, %q{ChangeLog}, %q{Gemfile}, %q{LICENSE.txt}, %q{README.md}, %q{Rakefile}, %q{Vagrantfile}, %q{bin/ey-visualvm}, %q{cookbooks/apt/README.md}, %q{cookbooks/apt/files/default/apt-cacher}, %q{cookbooks/apt/files/default/apt-cacher.conf}, %q{cookbooks/apt/files/default/apt-proxy-v2.conf}, %q{cookbooks/apt/metadata.json}, %q{cookbooks/apt/metadata.rb}, %q{cookbooks/apt/providers/repository.rb}, %q{cookbooks/apt/recipes/cacher-client.rb}, %q{cookbooks/apt/recipes/cacher.rb}, %q{cookbooks/apt/recipes/default.rb}, %q{cookbooks/apt/resources/repository.rb}, %q{cookbooks/gems/recipes/default.rb}, %q{cookbooks/java/README.md}, %q{cookbooks/java/attributes/default.rb}, %q{cookbooks/java/files/default/java.seed}, %q{cookbooks/java/metadata.json}, %q{cookbooks/java/metadata.rb}, %q{cookbooks/java/recipes/default.rb}, %q{cookbooks/java/recipes/openjdk.rb}, %q{cookbooks/java/recipes/sun.rb}, %q{cookbooks/jruby/attributes/default.rb}, %q{cookbooks/jruby/recipes/default.rb}, %q{cookbooks/server/recipes/default.rb}, %q{cookbooks/server/templates/default/server.sh.erb}, %q{cookbooks/vagrant_main/recipes/default.rb}, %q{engineyard-visualvm.gemspec}, %q{ext/org/jruby/ext/jmx/Agent.java}, %q{ext/org/jruby/ext/jmx/JavaHome.java}, %q{ext/org/jruby/ext/jmx/RMIServerSocketFactoryImpl.java}, %q{lib/engineyard-visualvm.rb}, %q{lib/engineyard-visualvm/agent.jar}, %q{lib/engineyard-visualvm/cli.rb}, %q{lib/engineyard-visualvm/version.rb}, %q{spec/engineyard-visualvm_spec.rb}, %q{spec/spec_helper.rb}]
  s.homepage = %q{https://github.com/engineyard/engineyard-visualvm}
  s.require_paths = [%q{lib}]
  s.rubyforge_project = %q{jruby-extras}
  s.rubygems_version = %q{1.8.9}
  s.summary = %q{Client and server helpers for using JMX and VisualVM with EY Cloud.}
  s.test_files = [%q{spec/engineyard-visualvm_spec.rb}, %q{spec/spec_helper.rb}]

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<childprocess>, [">= 0"])
      s.add_runtime_dependency(%q<engineyard>, [">= 0"])
      s.add_runtime_dependency(%q<jruby-openssl>, [">= 0"])
      s.add_runtime_dependency(%q<ffi-ncurses>, [">= 0"])
      s.add_development_dependency(%q<rspec>, [">= 0"])
    else
      s.add_dependency(%q<childprocess>, [">= 0"])
      s.add_dependency(%q<engineyard>, [">= 0"])
      s.add_dependency(%q<jruby-openssl>, [">= 0"])
      s.add_dependency(%q<ffi-ncurses>, [">= 0"])
      s.add_dependency(%q<rspec>, [">= 0"])
    end
  else
    s.add_dependency(%q<childprocess>, [">= 0"])
    s.add_dependency(%q<engineyard>, [">= 0"])
    s.add_dependency(%q<jruby-openssl>, [">= 0"])
    s.add_dependency(%q<ffi-ncurses>, [">= 0"])
    s.add_dependency(%q<rspec>, [">= 0"])
  end
end
