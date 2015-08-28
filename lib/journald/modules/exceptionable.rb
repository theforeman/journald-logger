module Journald
  class Logger
    module Exceptionable
      def exception(e, priority: nil, severity: nil)
        priority ||= severity_to_priority(severity) || Journald::LOG_ERR
        real_exception(e, priority, false)
      end

      private

        def real_exception(e, priority, is_cause)
          # get backtrace if present
          bt = e.backtrace_locations &&
               e.backtrace_locations.length > 0

          tag_trace_location(e.backtrace_locations[0]) if bt

          send(
              priority:                 priority,
              message:                  "Exception #{e.inspect}",
              gem_logger_message_type:  is_cause ? 'ExceptionCause' : 'Exception',
              exception_class:          e.class.name,
              exception_message:        e.message,
              backtrace:                bt ? e.backtrace.join("\n"): nil,
              cause:                    e.cause ? e.cause.inspect : nil,
          )

          untag_trace_location if bt

          real_exception(e.cause, priority, true) if e.cause
        end
    end
  end
end
