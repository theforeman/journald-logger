require 'logger'
require 'syslog/logger'
require 'journald/native'

require_relative 'logger/version'
require_relative 'logger/exceptionable'
require_relative 'logger/loggable'
require_relative 'logger/sysloggable'

module Journald
  class Logger
    # our map differs from Syslog::Logger
    LEVEL_MAP = {
        ::Logger::UNKNOWN => LOG_ALERT,
        ::Logger::FATAL   => LOG_CRIT,
        ::Logger::ERROR   => LOG_ERR,
        ::Logger::WARN    => LOG_WARNING,
        ::Logger::INFO    => LOG_INFO,
        ::Logger::DEBUG   => LOG_DEBUG,
    }

    include Exceptionable
    include Loggable
    include Sysloggable

    def initialize(progname = nil, tags = {})
      @tags   = tags
      @logger = Native
      self.progname = progname
    end

    def progname
      tag_value(:syslog_identifier)
    end

    def progname=(value)
      tag(:syslog_identifier, value)
    end

    # systemd-journal style

    # send systemd-journal message
    def send(hash)
      hash_to_send = @tags.merge(hash)
      real_send(hash_to_send)
    end

    def print(priority, message)
      send({
        priority: priority,
        message:  message,
      })
    end

    # add tags

    # add tag to all log messages
    def tag(key, value)
      @tags[key] = value

      if block_given?
        yield
        untag(key)
      end
    end

    # get tag value
    def tag_value(key)
      @tags[key]
    end

    # stop adding the tag
    def untag(key)
      @tags.delete(key)
    end

    private

      def real_send(hash)
        hash = hash.delete_if { |_, v| v.nil? }

        array_to_send = hash.map do |k,v|
          key = k.to_s.upcase
          value = v.to_s

          "#{key}=#{value}"
        end

        @logger.send(*array_to_send)
      end
  end
end
