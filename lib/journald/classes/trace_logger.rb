module Journald
  class TraceLogger
    def initialize(progname = nil, min_priority = nil, **tags)
      @wrapped_logger = ::Journald::Logger.new(progname, min_priority, **tags)
    end

    PASSTHROUGH_METHODS = [
      :tag,
      :tag_value,
      :untag,
      :progname,
      :progname=,
      :level,
      :level=,
      :sev_threshold,
      :sev_threshold=,
      :min_priority,
      :min_priority=,
    ]

    METHODS = (Journald::Logger.public_instance_methods(false) +
               Journald::Logger::Exceptionable.public_instance_methods(false) +
               Journald::Logger::Loggable.public_instance_methods(false) +
               Journald::Logger::Sysloggable.public_instance_methods(false))

    METHODS.each do |method|
      if PASSTHROUGH_METHODS.include? method
        define_method(method) do |*args, &block|
          @wrapped_logger.public_send(method, *args, &block)
        end
      else
        define_method(method) do |*args, &block|
          @wrapped_logger.__send__(:tag_trace_location, caller_locations(1..1).first)
          @wrapped_logger.public_send(method, *args, &block)
        end
      end
    end
  end
end
