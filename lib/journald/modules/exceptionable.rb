module Journald
  class Logger
    module Exceptionable
      def exception(e, priority: nil, severity: nil)
        priority ||= severity_to_priority(severity) || Journald::LOG_ERR
        real_exception(e, priority, false)
      end

      private

      def real_exception(e, priority, is_cause)
        # for Ruby 2.1 get cause if present
        cause = if e.respond_to? :cause; e.cause; end
        # for Ruby 2.1 get backtrace if present
        bt = e.respond_to?(:backtrace_locations) &&
             e.backtrace_locations &&
             e.backtrace_locations.length > 0

        tag_trace_location(e.backtrace_locations[0]) if bt

        send_message(
          priority: priority,
          message: "Exception #{e.inspect}",
          gem_logger_message_type: is_cause ? "ExceptionCause" : "Exception",
          exception_class: e.class.name,
          exception_message: e.message,
          backtrace: bt ? e.backtrace.join("\n") : nil,
          cause: cause ? cause.inspect : nil,
        )

        untag_trace_location if bt

        real_exception(cause, priority, true) if cause
      end
    end
  end
end
