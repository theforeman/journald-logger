require 'logger'
require 'journald/native'

require_relative 'modules/version'
require_relative 'modules/exceptionable'
require_relative 'modules/loggable'
require_relative 'modules/sysloggable'

require_relative 'trace_logger'

module Journald
  class Logger
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

    protected

      # used internally by exception() and TracerLogger
      def tag_trace_location(location)
        tag :code_file, location.path
        tag :code_line, location.lineno
        tag :code_func, location.label

        if block_given?
          yield
          untag_trace_location
        end
      end

      def untag_trace_location
        untag :code_file
        untag :code_line
        untag :code_func
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
