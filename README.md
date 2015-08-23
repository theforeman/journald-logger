# journald-logger

[![Gem Version](https://badge.fury.io/rb/journald-logger.svg)](http://badge.fury.io/rb/journald-logger)
[![Reference Status](https://www.versioneye.com/ruby/journald-logger/reference_badge.svg)](https://www.versioneye.com/ruby/journald-logger/references)

A Logger drop-in replacement that logs directly to systemd-journal with some additional features

## Usage

```ruby
require 'journald/logger'

logger = Journald::Logger.new('gandalf') # simple logger, sets SYSLOG_IDENTIFIER to 'gandalf'
logger = Journald::TraceLogger.new('gandalf') # tracing logger, logs caller's file, line number and function name
```

## Logger replacement

This gem is designed to be accurate drop-in Logger replacement

```ruby
logger.warn "you shall not pass!"           # works
logger.info("gollum") { "my preciousss" }   # also works!
logger.progname = "saruman"                 # sets value for SYSLOG_IDENTIFIER to 'saruman'
logger.formatter = SomeFormatter.new        # does nothing, journald-logger does not require a formatter
logger.close                                # does nothing, nothing to close
```

We map Ruby severity to Syslog priority by this map

```ruby
LEVEL_MAP = {
  ::Logger::UNKNOWN => LOG_ALERT,
  ::Logger::FATAL   => LOG_CRIT,
  ::Logger::ERROR   => LOG_ERR,
  ::Logger::WARN    => LOG_WARNING,
  ::Logger::INFO    => LOG_INFO,
  ::Logger::DEBUG   => LOG_DEBUG,
}
```

You may notice it's somewhat different from the one from Syslog::Logger

## Setting report level

```ruby
logger = Journald::Logger.new('gandalf', Journald::LOG_NOTICE) # set minimal reporting level to notice
logger.min_priority   = Journald::LOG_NOTICE # runtime change of minimal priority
logger.level          = Logger::WARN # use Logger severity
logger.sev_threshold  = Logger::INFO # please pay attention that Logger severity lacks several levels e.g. 'notice'
```

## Tags

Tags are used to add systemd-journal fields to all subsequent log calls until removed

```ruby
logger = Journald::Logger.new('gandalf', world: 'arda') # set world tag in costructor
logger.tag location: 'shire', weapon: 'staff' # add/replace location and weapon
logger.tag(location: 'moria', object: 'balrog') do # change location and use object in the block
  # log as 'MESSAGE=you shall not pass!', 'PRIORITY=4', 'LOCATION=moria', 'OBJECT=balrog', 'WORLD=arda', 'WEAPON=staff'
  logger.warn 'you shall not pass!'
end # return location & object to the previous state
# log as 'MESSAGE=That was not in canon!', 'PRIORITY=6', 'LOCATION=shire', 'WORLD=arda', 'WEAPON=staff'
logger.info 'That was not in canon!'
logger.untag :location # remove location
```

Tag names must follow systemd-journal fields naming convention:
letters, numbers, underscores, cannot begin with underscore. Library upcases all letters automatically

## systemd-journal style

Two methods which look similarly to native systemd-journal api

```ruby
logger.send(
  message: 'hi!',
  priority: Journald::LOG_NOTICE,
  any_field: 'any_value',
) # tags will be added here
logger.print Journald::LOG_NOTICE, 'hi!' # and here
```

## Syslog style

Just to add some more confusion you may use methods with syslog severity names prefixed with ```log_```

```ruby
logger.log_err 'Error'
logger.log_debug 'Debug'
```

## Exception logging

```ruby
begin
  raise "Aw, snap!"
rescue => e
  logger.exception e # log exception with LOG_ERR level by default
  logger.exception e, severity: Logger::WARN        # use Logger severity
  logger.exception e, priority: Journald::LOG_ALERT # use Syslog priority 
end
```

Exception logger automatically fills the following fields:

```
EXCEPTION_CLASS=ExceptionRealClassName
EXCEPTION_MESSAGE=Original exception message
BACKTRACE=full backtrace
CAUSE=exception cause
GEM_LOGGER_MESSAGE_TYPE=Exception
```

It also tries to log ```CODE_LINE```, ```CODE_FILE``` and ```CODE_FUNC``` and try to recurse into Cause and log it into a separate message with ```GEM_LOGGER_MESSAGE_TYPE=ExceptionCause```

## License

MIT, see LICENSE.txt
