require 'jmx-wrapper/version'
require 'thor'
require 'childprocess'
require 'socket'

module Jmx
  module Wrapper
    module Helpers
      def self.port_available?(port)
        begin
          tcps = TCPServer.new("127.0.0.1", port)
          true
        rescue Errno::EADDRINUSE
          false
        ensure
          tcps.close if tcps
        end
      end

      STARTING_PORT = 5900

      def self.next_free_port(start = STARTING_PORT)
        (start...start+100).each do |i|
          return i if port_available?(i)
        end
      end

      def user
        @user
      end

      def ssh?
        host && user || options[:ssh]
      end

      def ssh_host
        user ? "#{user}@#{host}" : host
      end

      def host
        @host ||= begin
                    match = /(.*)?@(.*)/.match options[:host]
                    if match
                      @user = match[1]
                      match[2]
                    else
                      @user = nil
                      options[:host]
                    end
                  end
      end

      def next_free_port
        Helpers.next_free_port(port)
      end

      def port
        @port ||= Numeric === options[:port] && options[:port] || STARTING_PORT
      end

      def jvm_arguments
        "-Dorg.jruby.jmxwrapper.agent.port=#{next_free_port} -javaagent:#{File.expand_path('../jmx-wrapper/agent.jar', __FILE__)}"
      end

      def jmx_service_url
        require 'jmx-wrapper/agent'
        require 'java'
        org.jruby.ext.jmxwrapper.Agent.make_jmx_service_url(host, port)
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
      class_option :port, :aliases => "-p", :type => :numeric, :default => STARTING_PORT.to_s,
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
      method_option :ssh, :type => :boolean, :desc => "Force VisualVM to connect through an ssh tunnel"
      def visualvm
        unless find_executable?("jvisualvm")
          warn "Could not find \`jvisualvm\'; do you need to install the JDK?"
          exit 1
        end

        if ssh?
          ssh_dest = ssh_host
          server_host, server_port = host, port
          @host, @port = "localhost", next_free_port
          @ssh_process = ChildProcess.build("ssh", "-NL", "#{@port}:#{@host}:#{server_port}", "#{ssh_dest}")
          @ssh_process.start
        end

        visualvm = ChildProcess.build("jvisualvm", "--openjmx", jmx_service_url.to_s)
        visualvm.start

        loop do
          visualvm.exited? && break
          sleep 1
        end

        @ssh_process.stop if @ssh_process
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
