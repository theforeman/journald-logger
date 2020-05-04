module Journald
  class Logger
    module Loggable
      # ruby Logger style

      # our map differs from Syslog::Logger
      LEVEL_MAP = {
        ::Logger::UNKNOWN => LOG_ALERT,
        ::Logger::FATAL => LOG_CRIT,
        ::Logger::ERROR => LOG_ERR,
        ::Logger::WARN => LOG_WARNING,
        ::Logger::INFO => LOG_INFO,
        ::Logger::DEBUG => LOG_DEBUG,
      }

      def add(severity, message = nil, progname = nil)
        priority = severity_to_priority(severity) || LEVEL_MAP[::Logger::UNKNOWN]

        # some black magic from Logger O__o
        progname ||= self.progname
        if message.nil?
          if block_given?
            message = yield
          else
            message = progname
            progname = self.progname
          end
        end

        send_message(
          priority: priority,
          message: message,
          syslog_identifier: progname,
        )
      end

      alias_method :log, :add

      # add methods a la Logger.warn or Logger.error
      ::Logger::Severity::constants.each do |severity|
        severity_key = severity.downcase
        severity_value = ::Logger::Severity.const_get(severity)

        define_method(severity_key) do |progname = nil, &block|
          add(severity_value, nil, progname, &block)
        end

        define_method("#{severity_key}?".to_sym) do
          priority = severity_to_priority(severity_value)
          self.min_priority >= priority
        end
      end

      def <<(value)
        debug(value)
      end

      # Logger accessors

      # journald always logs everything
      def level
        priority = self.min_priority
        LEVEL_MAP.select { |_, p| p <= priority }.keys.min
      end

      def level=(severity)
        self.min_priority = severity_to_priority(severity)
      end

      def silence(temporary_severity = nil, severity: nil, priority: nil)
        prev_priority = self.min_priority

        severity ||= temporary_severity

        temp_priority = if priority
            priority
          elsif severity
            severity_to_priority(severity)
          else
            LOG_ERR
          end

        self.min_priority = temp_priority

        yield self
      ensure
        self.min_priority = prev_priority
      end

      alias_method :silence_logger, :silence

      alias_method :sev_threshold, :level
      alias_method :sev_threshold=, :level=

      # journald does not require formatter or formatting
      def formatter; end
      def formatter=(_); end
      def datetime_format; end
      def datetime_format=(_); end

      def close; end

      private

      def severity_to_priority(severity)
        LEVEL_MAP[severity]
      end
    end
  end
end
