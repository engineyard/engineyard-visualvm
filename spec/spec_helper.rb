require 'rspec'
require 'jmx-wrapper'

module JmxWrapperSpecHelpers
  def silence(io = nil)
    require 'stringio'
    io = StringIO.new
    old_stdout = $stdout
    old_stderr = $stderr
    $stdout = io
    $stderr = io
    yield
    io.string
  ensure
    $stdout = old_stdout
    $stderr = old_stderr
  end

  alias capture silence
end

module ExecStub
  def exec(command)
    $last_exec_command = command
  end
end

RSpec.configure do |config|
  config.include JmxWrapperSpecHelpers
end
