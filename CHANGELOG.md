# Changelog

## v3.1.0

*March 30, 2020*

- Ruby 2.5 is minimum required version
- Fixed argument for Ruby 3.x

## v3.0.1

*May 6, 2020*

- Ruby 2.7 warning resolved

## v3.0.0

*December 3, 2019*

- Do not override Ruby send method (API change)

## v2.0.4

*October 9, 2018*

* Return support for ruby 2.0.0

## v2.0.3

*March 14, 2016*

- tag() now returns value returned from yield
- add silence_logger() alias for silence()

## v2.0.2

*August 28, 2015*

* [FIX] Fix silence implementation: should pass `self` to the block and return block result

## v2.0.1

*August 28, 2015*

* [FIX] Implement `Logger.silence` required by activerectord-session_store

## v2.0.0

*August 24, 2015*

- Gem now depends on Ruby 2.1
- Tag syntax changed to hash style _(this breaks all 1.x tag calls)_ and accepts multiple tags at once
- Tagging with block now restores previous tag values
- Removed `TracerLogger` alias for `TraceLogger`

## v1.1.1

*December 18, 2014*

- fix constructor incompatibility between 1.0 and 1.1
- fix failure in exception() when backtrace is nil

## v1.1.0

*December 17, 2014*

- Add minimum reporting level logic
- Exception default level changed to LOG_ERR

## v1.0.1

*December 11, 2014*

- TracerLogger rewritten no to use method_missing. This also fixes `send()` method. 
  Renamed to TraceLogger with backwards compatibility
- Some refactoring

## v1.0.0

*November 20, 2014*

Initial stable release
