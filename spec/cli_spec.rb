require File.expand_path('../spec_helper', __FILE__)

describe Jmx::Wrapper::CLI do
  let(:script) { Class.new(Jmx::Wrapper::CLI) }

  context "#url" do
    it "prints a JMX service URL" do
      capture { script.start(["url"]) }.should =~ /service:jmx:rmi/
    end

    it "allows the port number to be specified" do
      capture { script.start(["url", "--port=1234"]) }.should =~ /service:jmx:rmi.*:1234/
    end
  end

  context "#visualvm" do
    before :each do
      script.class_eval { include ExecStub }
    end

    it "starts jvisualvm with the service URL" do
      script.start(["visualvm"])
      $last_exec_command.should =~ /jvisualvm/
      $last_exec_command.should =~ /--openjmx/
      $last_exec_command.should =~ /service:jmx:rmi/
    end

    it "allows the port number to be specified" do
      script.start(["visualvm", "--port=1234"])
      $last_exec_command.should =~ /service:jmx:rmi.*:1234/
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
