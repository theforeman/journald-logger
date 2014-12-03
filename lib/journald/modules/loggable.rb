module Journald
  class Logger
    module Loggable
      # ruby Logger style

      # our map differs from Syslog::Logger
      LEVEL_MAP = {
          ::Logger::UNKNOWN => LOG_ALERT,
          ::Logger::FATAL   => LOG_CRIT,
          ::Logger::ERROR   => LOG_ERR,
          ::Logger::WARN    => LOG_WARNING,
          ::Logger::INFO    => LOG_INFO,
          ::Logger::DEBUG   => LOG_DEBUG,
      }

      def add(severity, message = nil, progname = nil, &block)
        priority = severity_to_priority(severity) || LEVEL_MAP[::Logger::UNKNOWN]

        # some black magic from Logger O__o
        progname ||= self.progname
        if message.nil?
          if block_given?
            message = block.call
          else
            message = progname
            progname = self.progname
          end
        end

        send({
            priority: priority,
            message:  message,
            syslog_identifier: progname,
        })
      end

      alias_method :log, :add

      # add methods a la Logger.warn or Logger.error
      ::Logger::Severity::constants.each do |severity|
        severity_key   = severity.downcase
        severity_value = ::Logger::Severity.const_get(severity)

        define_method(severity_key) do |progname = nil, &block|
          add(severity_value, nil, progname, &block)
        end

        define_method("#{severity_key}?".to_sym) do
          true # journald always logs everything
        end
      end

      def <<(value)
        debug(value)
      end

      # Logger accessors

      # journald always logs everything
      def level
        ::Logger::DEBUG
      end

      def sev_threshold
        ::Logger::DEBUG
      end

      def level=(_); end
      def sev_threshold=(_); end

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
