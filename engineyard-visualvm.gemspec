# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "engineyard-visualvm/version"

Gem::Specification.new do |s|
  s.name        = "engineyard-visualvm"
  s.version     = EngineYard::VisualVM::VERSION
  s.authors     = ["Nick Sieger"]
  s.email       = ["nick@nicksieger.com"]
  s.homepage    = ""
  s.summary     = %q{Client and server helpers for using JMX and VisualVM with EY Cloud.}
  s.description = %q{This provides a Java agent and command-line utility to enable
    JMX in any Java process such that it can be accessed through a firewall,
    and a VisualVM launcher aid to connect to that process through ssh.}

  s.rubyforge_project = "jruby-extras"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency "thor"
  s.add_runtime_dependency "childprocess"
  s.add_development_dependency "rspec"
end
