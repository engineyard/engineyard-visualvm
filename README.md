# engineyard-visualvm

`engineyard-visualvm` is a command-line utility for use with JRuby and
Engine Yard Cloud that makes it easy to connect Visual VM on a desktop
to a running JRuby or Java process in EY Cloud.

## Usage

To start Visual VM on your local machine to an already-running process:

    # Connect by EY Cloud environment and account
    $ ey-visualvm start --environment=jruby --account=example

(If you need to see a list of available environments and their
associated accounts, use the `ey environments` command from the
[engineyard](/engineyard/engineyard) gem.)

You can also use the `engineyard-visualvm` gem to connect Visual VM to
any host where you have an available ssh connection.

    # Connect by hostname:
    $ ey-visualvm start --host=deploy@example.com      

To connect to a server, the server must be booted with some additional
JVM arguments. These can be generated on the server side with:

    $ ey-visualvm jvmargs
    -Dorg.jruby.ext.jmx.agent.port=5900 -javaagent:/path/to/engineyard-visualvm/agent.jar

The server JVM binds to the loopback interface and listens on port
5900 by default. If you want to use a different interface and/or port
than the default, pass `--host=<host-or-ip>` or `--port=<port>` to
`ey-visualvm jvmargs`.

## Acceptance Test

To verify that a JMX connection to a server can be established, we can
use Vagrant and Chef to bootstrap a VM, start a JRuby process with JMX
enabled, create an ssh tunnel to the Vagrant box, and use the `jmx`
gem to connect to it from Ruby code. The code for this looks like
this:

```ruby
require 'childprocess'
require 'jmx'

sh "vagrant ssh_config > ssh_config.tmp"
sh "vagrant up"
at_exit { sh "vagrant halt"; rm_f "ssh_config.tmp" }

@host, @port = 'localhost', 5900

ssh = ChildProcess.build("ssh", "-NL", "#{@port}:#{@host}:#{@port}", "-F", "ssh_config.tmp", "default")
ssh.start
at_exit { ssh.stop }

require 'engineyard-visualvm'
include EngineYard::VisualVM::Helpers
server = JMX::MBeanServer.new jmx_service_url

runtime_config_name = server.query_names('org.jruby:type=Runtime,name=*,service=Config').to_a.first
puts "Found runtime #{runtime_config_name}"
runtime_config = server[runtime_config_name]
puts "Runtime version: #{runtime_config['VersionString']}"
puts "OK"
```

To try it yourself, do the following:

    # Ensure you have vagrant and jmx installed
    $ bundle install

    # Run the acceptance test
    $ rake acceptance
    vagrant ssh_config > ssh_config.tmp
    vagrant up
    # ... bunch of output as the VM boots and Chef runs...
    [default] [Tue, 22 Nov 2011 19:52:41 -0800] INFO: execute[start server] ran successfully
    [Tue, 22 Nov 2011 19:52:41 -0800] INFO: Chef Run complete in 35.157236 seconds
    [Tue, 22 Nov 2011 19:52:41 -0800] INFO: Running report handlers
    [Tue, 22 Nov 2011 19:52:41 -0800] INFO: Report handlers complete
    : stdout
    Found runtime org.jruby:type=Runtime,name=25292276,service=Config
    Runtime version: jruby 1.6.5 (ruby-1.8.7-p330) (2011-10-25 9dcd388) (Java HotSpot(TM) Client VM 1.6.0_26) [linux-i386-java]
    OK
    vagrant halt
    [default] Attempting graceful shutdown of linux...
    rm -f ssh_config.tmp

## Bits and Pieces

- Gem: `gem install engineyard-visualvm`
- Source: https://github.com/engineyard/engineyard-visualvm
- License: MIT; see LICENSE.txt for details.

## TODO

- Prompt for a JVM to connect to if more than one JVM process is
  running on the server
- Data collected by `jstatd` is not yet supported, so things like the
  Visual GC tab are not supported yet.
- Additional utilities to make use of the JMX connection remotely
