# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "jmx-wrapper/version"

Gem::Specification.new do |s|
  s.name        = "jmx-wrapper"
  s.version     = Jmx::Wrapper::VERSION
  s.authors     = ["Nick Sieger"]
  s.email       = ["nick@nicksieger.com"]
  s.homepage    = ""
  s.summary     = %q{Start a Java process with a firewall-friendly JMX setup.}
  s.description = %q{This provides a Java agent and a small script to aid in starting
    JMX in any Java process such that it can be accessed through a firewall
    (e.g., with ssh port forwarding.)}

  s.rubyforge_project = "jruby-extras"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency "thor"
  s.add_development_dependency "rspec"
end
