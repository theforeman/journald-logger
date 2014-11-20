module Journald
  class Logger
    module Exceptionable
      def exception(e, priority = Journald::LOG_CRIT)
        real_exception(e, priority, false)
      end

      private

        def real_exception(e, priority, is_cause)
          cause = nil
          cause = e.cause if e.respond_to? :cause

          send({
              priority:                 priority,
              message:                  "Exception #{e.inspect}",
              gem_logger_message_type:  is_cause ? 'ExceptionCause' : 'Exception',
              exception_class:          e.class.name,
              exception_message:        e.message,
              backtrace:                e.backtrace.join("\n"),
              cause:                    cause ? cause.inspect : nil,
          })

          real_exception(cause, priority, true) if cause
        end
    end
  end
end
