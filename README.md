# journald-logger

A Logger drop-in replacement that logs directly to systemd-journal with some additional features

## Usage

```ruby
require 'journald/logger'

logger = Journald::Logger.new('gandalf') # simple logger, sets SYSLOG_IDENTIFIER to 'gandalf'
logger = Journald::TracerLogger.new('gandalf') # tracing logger, logs caller's file, line number and function name
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

## Tags

Tags are used to add systemd-journal fields to all subsequent log calls until removed

```ruby
logger = Journald::Logger.new('gandalf', world: 'arda') # set world tag in costructor
logger.tag :location, 'moria' # add/replace location
logger.tag(:object, 'balrog') do # use object field in the block
  # log as 'MESSAGE=you shall not pass!', 'PRIORITY=4', 'LOCATION=moria', 'OBJECT=balrog', 'WORLD=arda'
  logger.warn 'you shall not pass!'
end
logger.untag :location # remove location
```

Tag names must follow systemd-journal fields naming convention:
letters, numbers, underscores, cannot begin with underscore. Library upcases all letters automatically

## systemd-journal style

Two methods which look similarly to native systemd-journal api

```ruby
logger.send({
  message: 'hi!',
  priority: Journald::LOG_NOTICE,
  any_field: 'any_value',
}) # tags will be added here
logger.print Journald::LOG_NOTICE, 'hi!' # and here
```

## Syslog style

Just to add some more confusion you may use methods with syslog severity names prefixed with ```log_```

```ruby
logger.log_err 'Error'
logger.log_debug 'Debug'
```

## License

MIT, see LICENSE.txt
