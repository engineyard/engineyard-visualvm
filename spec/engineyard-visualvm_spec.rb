#--
# Copyright (c) 2011 Engine Yard, Inc.
# See the file LICENSE.txt included with the distribution for
# software license details.
#++

require File.expand_path('../spec_helper', __FILE__)

describe EngineYard::VisualVM::Helpers do
  context "when included in a class"
  let(:object) do
    clz = Class.new
    clz.class_eval { include EngineYard::VisualVM::Helpers }
    clz.new
  end

  it "can calculate JVM arguments" do
    object.jvm_arguments.tap {|args|
      args.should =~ /org\.jruby\.jmx\.agent/
      args.should =~ /javaagent:.*agent\.jar/
    }
  end
end

describe EngineYard::VisualVM::CLI do
  let(:script) { Class.new(EngineYard::VisualVM::CLI) { include SystemDouble } }

  context "#help" do
    it "prints the default port" do
      capture { script.start(["help", "start"]) }.should =~ /Default:/
    end
  end

  context "#url" do
    it "prints a JMX service URL" do
      capture { script.start(["url"]) }.should =~ /service:jmx:rmi/
    end

    it "allows the port number to be specified" do
      capture { script.start(["url", "--port=1234"]) }.should =~ /service:jmx:rmi.*:1234/
    end
  end

  context "#start" do
    let(:system_double) { double("system").tap {|d| script.system_double = d } }
    let(:ssh_process) { double("ssh process double").tap {|d| d.should_receive(:start) } }
    let(:visualvm_process) do
      double("visualvm process double").tap {|d|
        d.should_receive(:start)
        d.should_receive(:exited?).and_return(true)
      }
    end

    before :each do
      script.class_eval do
        no_tasks { define_method(:fetch_environment) { raise EY::Error, "error" } }
      end
    end

    it "starts jvisualvm with the service URL" do
      ChildProcess.should_receive(:build).and_return do |*args|
        args[0].should == "jvisualvm"
        args[1].should == "--openjmx"
        args[2].should =~ /service:jmx:rmi/
        visualvm_process
      end
      script.start(["start"])
    end

    it "allows the port number to be specified" do
      ChildProcess.should_receive(:build).and_return do |*args|
        args[2].should =~ /service:jmx:rmi.*:1234/
        visualvm_process
      end
      script.start(["start", "--port=1234"])
    end

    it "allows the host to be specified" do
      ChildProcess.should_receive(:build).and_return do |*args|
        args[2].should =~ /service:jmx:rmi.*example.com:/
        visualvm_process
      end
      script.start(["start", "--host=example.com"])
    end

    it "sets up an ssh tunnel if the user@host format is used" do
      system_double.should_receive(:system).with("ssh user@example.com true").ordered.and_return true
      ChildProcess.should_receive(:build).ordered.and_return do |*args|
        args.join(' ').should =~ /ssh -NL.*user@example.com/
        ssh_process
      end
      ChildProcess.should_receive(:build).ordered.and_return do |*args|
        args[2].should =~ /service:jmx:rmi.*localhost:/
        visualvm_process
      end
      ssh_process.should_receive(:stop)

      script.start(["start", "--host=user@example.com"])
    end

    it "allows an ssh tunnel to be forced" do
      system_double.should_receive(:system).ordered.and_return true
      ChildProcess.should_receive(:build).ordered.and_return do |*args|
        args.join(' ').should =~ /ssh -NL/
        ssh_process
      end
      ChildProcess.should_receive(:build).ordered.and_return do |*args|
        args[2].should =~ /service:jmx:rmi.*localhost:/
        visualvm_process
      end
      ssh_process.should_receive(:stop)

      script.start(["start", "--ssh"])
    end

    context "with a port conflict" do
      before :each do
        @port = EngineYard::VisualVM::Helpers.next_free_port
        @server = TCPServer.new("127.0.0.1", @port)
        @next_port = EngineYard::VisualVM::Helpers.next_free_port
      end

      after :each do
        @server.close; @server = nil
      end

      it "finds an open port for the local side of the ssh tunnel" do
        system_double.should_receive(:system).ordered.and_return true
        ChildProcess.should_receive(:build).ordered.and_return do |*args|
          args.join(' ').should =~ /ssh -NL #{@next_port}:localhost:#{@port}/
          ssh_process
        end
        ChildProcess.should_receive(:build).ordered.and_return do |*args|
          args[2].should =~ /service:jmx:rmi.*localhost:/
          visualvm_process
        end
        ssh_process.should_receive(:stop)

        script.start(["start", "--ssh", "--port=#{@port}"])
      end
    end

    context "with --environment specified" do
      let(:environment) do
        double(:environment).tap {|e|
          e.stub!(:username).and_return "deploy"
        }
      end
      before :each do
        env = environment
        script.class_eval do
          no_tasks { define_method(:fetch_environment) { env } }
        end
      end

      it "sets the user to 'deploy' and the host to the load balancer IP address" do
        system_double.should_receive(:system).ordered.and_return true
        environment.stub!(:load_balancer_ip_address).and_return "0.0.0.0"
        ChildProcess.should_receive(:build).ordered.and_return do |*args|
          args.join(' ').should =~ /ssh -NL.* deploy@0.0.0.0/
          ssh_process
        end
        ChildProcess.should_receive(:build).ordered.and_return do |*args|
          args[2].should =~ /service:jmx:rmi.*localhost:/
          visualvm_process
        end
        ssh_process.should_receive(:stop)

        script.start(["start", "--environment=jruby"])
      end

      it "uses the public hostname of the first instance if no load balancer" do
        system_double.should_receive(:system).ordered.and_return true
        environment.stub!(:load_balancer_ip_address).and_return nil
        environment.stub!(:instances).and_return [double("instance").tap{|d| d.stub!(:public_hostname).and_return "example.com" }]
        ChildProcess.should_receive(:build).ordered.and_return do |*args|
          args.join(' ').should =~ /ssh -NL.* deploy@example.com/
          ssh_process
        end
        ChildProcess.should_receive(:build).ordered.and_return do |*args|
          args[2].should =~ /service:jmx:rmi.*localhost:/
          visualvm_process
        end
        ssh_process.should_receive(:stop)

        script.start(["start", "--environment=jruby"])
      end
    end
  end

  context "#jvmargs" do
    it "prints the arguments for the server VM" do
      output = capture { script.start(["jvmargs"]) }
      output.should =~ /-Dorg\.jruby\.jmx\.agent\.port=/
      output.should =~ /-javaagent:.*agent\.jar/
    end

    it "allows the port number to be specified" do
      capture { script.start(["jvmargs", "--port=1234"]) }.should =~ /-Dorg\.jruby\.jmx\.agent\.port=1234/
    end
  end
end
