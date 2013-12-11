# log2sock

log2sock allows you to send logs to a UNIX domain socket. Its usage is similar to the Ruby 'logger' class, except with slightly less features.

## Installation

`gem install log2sock`

# Usage

## Reading logs on a socket

A small tool is included in this gem to help you read log messages on a UNIX domain socket.

```
Usage: log2read [<OPTIONS>]

OPTIONS
        --colour, --color            Default: no colour
        --socket=<filename>          Default: /tmp/log2.sock
        --help                       Display this help
```

### Example

```
# Let's assume you're using RBENV
~/.rbenv/shims/log2read --socket=/tmp/mylogs.sock --colour`
```

This command creates a socket at `/tmp/mylogs.sock` and enables colourized log output.

## Writing logs to a socket

Add this to your app and start logging stuff to a UNIX domain socket.

Example:

```
require 'log2sock'

logger = Log2sock.new("/tmp/mylogs.sock")
logger.level(Log2sock::INFO)
logger.debug("This is a debug message")                   # This won't be displayed
logger.info("This is an info message")                    # This will be displayed
logger.debug { "This is something really stupid #{5/0}" } # This won't be evaluated
logger.level(Log2sock::DEBUG)
logger.debug { "This is something really stupid #{5/0}" } # lulz
```

## Notes

* If the socket can't be used (ex: if it doesn't exist), the logs will be sent to STDOUT.
* The default socket is: `/tmp/log2.sock` which also exists in the CONSTANT `Log2sock::DEFAULT_SOCKET`
* There are 6 log levels: `DEBUG < INFO < WARN < ERROR < FATAL < UNKNOWN`
* Each log level is a constant (ex: `Log2sock::INFO`)
* The default log level is: `Log2sock::DEBUG`
* The `log2read` tool creates a socket with file permissions 750
* Press Ctrl+C to exit the log2read tool

## Requirements

* Ruby 1.9.x or greater

## LICENSE

MIT License, see the LICENSE file
