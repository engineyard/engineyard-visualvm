require "jmx-wrapper/version"
require 'thor'
require 'thor/group'

module Jmx
  module Wrapper
    OPTIONS = {
      :print => { :aliases => "-n", :type => :boolean, :default => false,
        :desc => "Print arguments to pass to JVM but don't launch" },
      :port =>  { :aliases => "-p", :type => :numeric, :default => 5900,
        :desc => "Port where the JMX agent runs" }
    }

    class Server < Thor::Group
      class_option :print, OPTIONS[:print]
      argument :args, :type => :array, :default => [],
        :desc => "Arguments to pass to the JVM", :banner => "[jvm args...]"
      def server
        puts "server #{args.inspect} #{options.inspect}"
      end
    end

    class CLI < Thor
      class_option :port, OPTIONS[:port]

      method_option :print, OPTIONS[:print]
      register Server, "server", "server [JVM ARGS]", "Launch the Java JMX server process"

      desc "url", "Show the connection URL for the JMX server process"
      def url
        puts "url #{options.inspect}"
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
