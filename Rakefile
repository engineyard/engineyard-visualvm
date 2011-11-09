require "bundler/gem_tasks"
require "rake/clean"

desc "Compile and jar the agent extension class"
begin
  require 'ant'
  jar_file = "lib/jmx-wrapper/agent.jar"
  directory "pkg/classes"

  file jar_file => FileList['ext/**/*.java'] do
    ant.javac :srcdir => "ext", :destdir => "pkg/classes",
      :source => "1.5", :target => "1.5", :debug => true,
      :classpath => "${java.class.path}:${sun.boot.class.path}",
      :includeantRuntime => false

    ant.jar :basedir => "pkg/classes", :destfile => jar_file, :includes => "**/*.class" do
      manifest do
        attribute :name => "Premain-Class", :value => "org.jruby.jmxwrapper.Agent"
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

task :default => :build
