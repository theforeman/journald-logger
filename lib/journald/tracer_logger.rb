module Journald
  class TracerLogger
    def initialize(progname = nil, tags = {})
      @wrapped_logger = Logger.new(progname, tags)
    end

    def method_missing(meth, *args, &block)
      super unless @wrapped_logger.respond_to? meth

      @wrapped_logger.__send__(:tag_trace_location, caller_locations[0])
      @wrapped_logger.__send__(meth, *args, &block)
    end

    def respond_to_missing?(method_name, include_private = false)
      @wrapped_logger.respond_to?(method_name, include_private)
    end
  end
end
