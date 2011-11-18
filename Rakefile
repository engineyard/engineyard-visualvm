require "bundler/gem_tasks"
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
