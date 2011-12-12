#--
# Copyright (c) 2011 Engine Yard, Inc.
# See the file LICENSE.txt included with the distribution for
# software license details.
#++

require 'rspec'
require 'engineyard-visualvm'

module EYVisualVMSpecHelpers
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

module SystemDouble
  def self.included(base)
    def base.system_double
        @@double
    end
    def base.system_double=(d)
      @@double = d
    end
  end

  def system_double
    @@double
  end

  def system(*args)
    system_double.system(*args)
  end
end

RSpec.configure do |config|
  config.include EYVisualVMSpecHelpers
end
