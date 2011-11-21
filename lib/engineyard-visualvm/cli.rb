#--
# Copyright (c) 2011 Engine Yard, Inc.
# See the file LICENSE.txt included with the distribution for
# software license details.
#++

require "thor"
require "childprocess"
require "socket"
require "engineyard"
require "engineyard/cli"
require "engineyard/thor"

module EngineYard
  module VisualVM
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

      def environment
        @environment ||= begin
                           fetch_environment(options[:environment], options[:account]).tap {|env|
                             @user = "deploy"
                             @host = fetch_public_ip(env)
                           }
                         rescue EY::Error
                           raise if options[:environment]
                           nil
                         end
      end

      def user
        @user
      end

      def ssh?
        environment || (host && user) || options[:ssh]
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
        "-Dorg.jruby.jmx.agent.port=#{next_free_port} -javaagent:#{File.expand_path('../engineyard-visualvm/agent.jar', __FILE__)}"
      end

      def jmx_service_url
        require 'engineyard-visualvm/agent'
        require 'java'
        org.jruby.ext.jmx.Agent.make_jmx_service_url(host, port)
      end

      def find_executable?(exe)
        ENV['PATH'].split(File::PATH_SEPARATOR).detect do |path|
          File.exist?(File.join(path, exe))
        end
      end

      # Return the public IP assigned to an environment (which may or
      # may not be a booted cluster of instances) Displays error and
      # exits if no public IP assigned to the environment
      def fetch_public_ip(environment)
        unless environment.load_balancer_ip_address
          warn "#{environment.account.name}/#{environment.name} has no assigned public IP address."
        end

        environment.load_balancer_ip_address
      end
    end

    class CLI < Thor
      include EY::UtilityMethods
      include Helpers

      class_option :host, :aliases => ["-H"], :default => "localhost",
        :desc => "Host or IP where the JMX agent runs"
      class_option :port, :aliases => ["-p"], :type => :numeric, :default => STARTING_PORT.to_s,
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
        puts "ey-visualvm version #{EngineYard::VisualVM::VERSION}"
      end

      desc "start", "Launch VisualVM to connect to the server.\nUse either the environment/account or host/port options."
      method_option :ssh, :type => :boolean, :desc => "Force VisualVM to connect through an ssh tunnel"
      method_option :environment, :aliases => ["-e"], :desc => "Environment containing the IP to which to resolve", :type => :string
      method_option :account,     :aliases => ["-c"], :desc => "Name of the account where the environment is found"
      def start
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
      rescue EY::Error => e
        warn e.message
        exit 2
      end

      def help(task = nil, *args)
        unless task
          puts "usage: ey-visualvm <task> [options|arguments]"
          puts "Make JMX and VisualVM more accessible to your server-side JVM."
          puts
        end
        super
      end
    end
  end
end
