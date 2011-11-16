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

module ExecDouble
  def self.included(base)
    def base.exec_double
        @@double
    end
    def base.exec_double=(d)
      @@double = d
    end
  end

  def exec_double
    @@double
  end

  def exec(*args)
    exec_double.exec(*args)
  end
end

RSpec.configure do |config|
  config.include JmxWrapperSpecHelpers
end
