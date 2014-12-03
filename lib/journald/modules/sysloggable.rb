module Journald
  class Logger
    module Sysloggable
      # methods with syslog priorities like logger.log_err, logger.log_warning
      [:LOG_EMERG, :LOG_ALERT, :LOG_CRIT, :LOG_ERR, :LOG_WARNING, :LOG_NOTICE, :LOG_INFO, :LOG_DEBUG].each do |level|
        define_method(level.downcase) do |message = nil, &block|
          message ||= block.call
          print(Journald.const_get(level), message)
        end
      end
    end
  end
end
