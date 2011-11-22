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
