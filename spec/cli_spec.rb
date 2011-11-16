require File.expand_path('../spec_helper', __FILE__)

describe Jmx::Wrapper::CLI do
  let(:script) { Jmx::Wrapper::CLI }

  context "#help" do
    it "prints the default port" do
      capture { script.start(["help", "visualvm"]) }.should =~ /Default:/
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

  context "#visualvm" do
    let(:ssh_process) { double("ssh process double").tap {|d| d.should_receive(:start) } }
    let(:visualvm_process) { double("visualvm process double").tap {|d| d.should_receive(:start); d.should_receive(:exited?).and_return(true) } }

    it "starts jvisualvm with the service URL" do
      ChildProcess.should_receive(:build).and_return do |*args|
        args[0].should == "jvisualvm"
        args[1].should == "--openjmx"
        args[2].should =~ /service:jmx:rmi/
        visualvm_process
      end
      script.start(["visualvm"])
    end

    it "allows the port number to be specified" do
      ChildProcess.should_receive(:build).and_return do |*args|
        args[2].should =~ /service:jmx:rmi.*:1234/
        visualvm_process
      end
      script.start(["visualvm", "--port=1234"])
    end

    it "allows the host to be specified" do
      ChildProcess.should_receive(:build).and_return do |*args|
        args[2].should =~ /service:jmx:rmi.*example.com:/
        visualvm_process
      end
      script.start(["visualvm", "--host=example.com"])
    end

    it "sets up an ssh tunnel if the user@host format is used" do
      ChildProcess.should_receive(:build).ordered.and_return do |*args|
        args.join(' ').should =~ /ssh -NL.*user@example.com/
        ssh_process
      end
      ChildProcess.should_receive(:build).ordered.and_return do |*args|
        args[2].should =~ /service:jmx:rmi.*localhost:/
        visualvm_process
      end
      ssh_process.should_receive(:stop)

      script.start(["visualvm", "--host=user@example.com"])
    end

    it "allows an ssh tunnel to be forced" do
      ChildProcess.should_receive(:build).ordered.and_return do |*args|
        args.join(' ').should =~ /ssh -NL/
        ssh_process
      end
      ChildProcess.should_receive(:build).ordered.and_return do |*args|
        args[2].should =~ /service:jmx:rmi.*localhost:/
        visualvm_process
      end
      ssh_process.should_receive(:stop)

      script.start(["visualvm", "--ssh"])
    end

    context "with a port conflict" do
      before :each do
        @port = Jmx::Wrapper::Helpers.default_port
        @server = TCPServer.new("127.0.0.1", @port)
        @next_port = Jmx::Wrapper::Helpers.default_port
      end

      after :each do
        @server.close; @server = nil
      end

      it "finds an open port for the local side of the ssh tunnel" do
        ChildProcess.should_receive(:build).ordered.and_return do |*args|
          args.join(' ').should =~ /ssh -NL #{@next_port}:localhost:#{@port}/
          ssh_process
        end
        ChildProcess.should_receive(:build).ordered.and_return do |*args|
          args[2].should =~ /service:jmx:rmi.*localhost:/
          visualvm_process
        end
        ssh_process.should_receive(:stop)

        script.start(["visualvm", "--ssh", "--port=#{@port}"])
      end
    end
  end

  context "#jvmargs" do
    it "prints the arguments for the server VM" do
      output = capture { script.start(["jvmargs"]) }
      output.should =~ /-Dorg\.jruby\.jmxwrapper\.agent\.port=/
      output.should =~ /-javaagent:.*agent\.jar/
    end

    it "allows the port number to be specified" do
      capture { script.start(["jvmargs", "--port=1234"]) }.should =~ /-Dorg\.jruby\.jmxwrapper\.agent\.port=1234/
    end
  end
end
