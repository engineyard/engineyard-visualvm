require "bundler/gem_tasks"

desc "Compile and jar the agent extension class"
begin
  require 'ant'
  task :jar => :compile do
    ant.jar :basedir => "pkg/classes", :destfile => "pkg/jmx-wrapper-agent.jar", :includes => "*.class" do
      manifest do
        attribute :name => "Premain-Class", :value => "org.jruby.jmxwrapper.Agent"
      end
    end
  end

  directory "pkg/classes"
  task :compile => "pkg/classes" do |t|
    ant.javac :srcdir => "ext", :destdir => t.prerequisites.first,
      :source => "1.5", :target => "1.5", :debug => true,
      :classpath => "${java.class.path}:${sun.boot.class.path}",
      :includeantRuntime => false
  end
rescue LoadError
  task :jar do
    puts "Run 'jar' with JRuby to re-compile the agent extension class"
  end
end

# Make sure jar gets compiled before the gem is built
task Rake::Task['build'].prerequisites.first => :jar

task :default => :build
