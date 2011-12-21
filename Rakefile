#--
# Copyright (c) 2011 Engine Yard, Inc.
# See the file LICENSE.txt included with the distribution for
# software license details.
#++

require "rake/clean"

desc "Compile and jar the agent extension class"
begin
  require 'ant'
  jar_file = "lib/engineyard-visualvm/agent.jar"
  directory "pkg/classes"
  CLEAN << "pkg"

  file jar_file => FileList['ext/**/*.java', 'pkg/classes'] do
    rm_rf FileList['pkg/classes/**/*']
    ant.javac :srcdir => "ext", :destdir => "pkg/classes",
      :source => "1.5", :target => "1.5", :debug => true,
      :classpath => "${java.class.path}:${sun.boot.class.path}",
      :includeantRuntime => false

    ant.jar :basedir => "pkg/classes", :destfile => jar_file, :includes => "**/*.class" do
      manifest do
        attribute :name => "Premain-Class", :value => "org.jruby.ext.jmx.Agent"
      end
    end
  end

  task :jar => jar_file
rescue LoadError
  task :jar do
    puts "Run 'jar' with JRuby to re-compile the agent extension class"
  end
end

# Make sure jar gets compiled before the gem is built
task :build => :jar

task :default => :spec

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new

task :spec => :jar

## Bundler tasks
gemspec_in = FileList['*.gemspec.in'].first
gemspec = gemspec_in.sub(/\.in/, '')
gemspec_java = gemspec.sub(/\.gemspec/, '-java.gemspec')
write_gemspecs = lambda {
  File.open(gemspec, 'w') {|f| f << eval(File.read(gemspec_in)).to_ruby }
  File.open(gemspec_java, 'w') {|f| use_jruby = true; f << eval(File.read(gemspec_in)).to_ruby }
}
write_gemspecs.call unless File.exist?(gemspec) && File.exist?(gemspec_java)

task :update_gemspecs do
  write_gemspecs.call
end
task :build => :update_gemspecs
task :install => :update_gemspecs
task :release => :update_gemspecs

require "bundler/gem_helper"

Bundler::GemHelper.install_tasks(:name => gemspec.sub('.gemspec', ''))
namespace :java do
  gh = Bundler::GemHelper.new(Dir.pwd, gemspec_java.sub('.gemspec', ''))
  # These are no-ops since we will have already tagged and pushed
  def gh.guard_already_tagged; end
  def gh.tag_version; yield if block_given?; end
  def gh.git_push; end
  gh.install
end

task :build do
  Rake::Task["java:build"].invoke
end
task :release do
  Rake::Task["java:release"].invoke
end

# Override push to use engineyard key
class Bundler::GemHelper
  def rubygem_push(path)
    if Gem.configuration.api_keys.key? :engineyard
      sh("gem push -k engineyard '#{path}'")
      Bundler.ui.confirm "Pushed #{name} #{version} to rubygems.org"
    else
      raise ":engineyard key not set in ~/.gem/credentials"
    end
  end
end

## Acceptance task
begin
  require 'childprocess'
  require 'jmx'
  task :acceptance => :build do
    sh "vagrant ssh_config > ssh_config.tmp"
    sh "vagrant up"
    at_exit { sh "vagrant halt"; rm_f "ssh_config.tmp" }

    @host, @port = 'localhost', 5900

    ssh = ChildProcess.build("ssh", "-NL", "#{@port}:#{@host}:#{@port}", "-F", "ssh_config.tmp", "default")
    ssh.start
    at_exit { ssh.stop }

    require 'engineyard-visualvm'
    include EngineYard::VisualVM::Helpers
    server = JMX::MBeanServer.new jmx_service_url

    runtime_config_name = server.query_names('org.jruby:type=Runtime,name=*,service=Config').to_a.first
    puts "Found runtime #{runtime_config_name}"
    runtime_config = server[runtime_config_name]
    puts "Runtime version: #{runtime_config['VersionString']}"
    puts "OK"
  end
rescue LoadError
  task :acceptance do
    fail "Run 'acceptance' with JRuby to actually run the test"
  end
end
