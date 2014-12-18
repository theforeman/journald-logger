module Journald
  class Logger
    include Exceptionable
    include Loggable
    include Sysloggable

    def initialize(progname = nil, min_priority = nil, tags = {})
      if progname.is_a? Hash
        tags = progname
        progname = min_priority = nil
      end

      if min_priority.is_a? Hash
        tags = min_priority
        min_priority = nil
      end

      @tags   = tags
      @logger = Native
      self.min_priority = min_priority
      self.progname = progname
    end

    def progname
      tag_value(:syslog_identifier)
    end

    def progname=(value)
      tag(:syslog_identifier, value)
    end

    attr_reader :min_priority

    def min_priority=(value)
      @min_priority = value ? value.to_i : ::Journald::LOG_DEBUG
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

      # used internally by exception() and TraceLogger
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

          if key == 'PRIORITY'
            priority = value.to_i

            return 0 if priority > @min_priority # DEBUG = 7, ALERT = 1
          end

          "#{key}=#{value}"
        end

        @logger.send(*array_to_send)
      end
  end
end
