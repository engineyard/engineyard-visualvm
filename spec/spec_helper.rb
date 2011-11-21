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

RSpec.configure do |config|
  config.include EYVisualVMSpecHelpers
end
