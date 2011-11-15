require 'jmx-wrapper/version'
require 'thor'

module Jmx
  module Wrapper
    module Helpers
      def jvm_arguments
        "-Dorg.jruby.jmxwrapper.agent.port=#{options[:port]} -javaagent:#{File.expand_path('../jmx-wrapper/agent.jar', __FILE__)}"
      end

      def jmx_service_url
        require 'jmx-wrapper/agent'
        require 'java'
        org.jruby.ext.jmxwrapper.Agent.make_jmx_service_url(options[:host], options[:port])
      end

      def find_executable?(exe)
        ENV['PATH'].split(File::PATH_SEPARATOR).detect do |path|
          File.exist?(File.join(path, exe))
        end
      end
    end

    class CLI < Thor
      include Helpers
      class_option :host, :aliases => "-H", :default => "localhost",
        :desc => "Host or IP where the JMX agent runs"
      class_option :port, :aliases => "-p", :type => :numeric, :default => 5900,
        :desc => "Port where the JMX agent runs"

      desc "jvmargs", "Print the arguments to be passed to the server JVM"
      def jvmargs
        puts jvm_arguments
      end

      desc "url", "Print the connection URL for the JMX server process"
      def url
        puts jmx_service_url
      end

      desc "version", "Show version"
      def version
        puts "jmx-wrapper version #{Jmx::Wrapper::VERSION}"
      end

      desc "visualvm", "Launch VisualVM to connect to the server"
      def visualvm
        unless find_executable?("jvisualvm")
          warn "Could not find jvisualvm; do you need to install the JDK?"
          exit 1
        end
        exec "jvisualvm --openjmx #{jmx_service_url}"
      end

      def help(task = nil, *args)
        unless task
          puts "usage: jmx-wrapper <task> [options|arguments]"
          puts "Make JMX more accessible to your server and/or client programs."
          puts
        end
        super
      end
    end
  end
end
