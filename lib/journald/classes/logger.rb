module Journald
  class Logger
    TAG_CONTEXTS_THREAD_KEY = :journald_logger_tag_contexts

    include Exceptionable
    include Loggable
    include Sysloggable

    def initialize(progname = nil, min_priority = nil, **tags)
      @tags = tags
      @logger = Native
      self.min_priority = min_priority
      self.progname = progname
    end

    def progname
      tag_value(:syslog_identifier)
    end

    def progname=(value)
      tag(syslog_identifier: value)
    end

    attr_reader :min_priority

    def min_priority=(value)
      @min_priority = value ? value.to_i : ::Journald::LOG_DEBUG
    end

    # systemd-journal style

    # send systemd-journal message
    def send_message(hash)
      hash_to_send = @tags.merge(scoped_tag_values).merge(hash)
      real_send(hash_to_send)
    end

    def print(priority, message)
      send_message(
        priority: priority,
        message: message,
      )
    end

    # add tags

    # add tags to all log messages
    def tag(**tags)
      if block_given?
        with_scoped_tags(tags) { yield self }
      else
        (current_tag_frame || @tags).merge!(tags)
        tags
      end
    end

    # get tag value
    def tag_value(key)
      values = scoped_tag_values
      values.key?(key) ? values[key] : @tags[key]
    end

    # get tag values
    # return everything including nil for non-set
    def tag_values(*keys)
      keys.inject({}) { |hash, key| hash[key] = tag_value(key); hash }
    end

    # stop adding the tag
    def untag(*keys)
      current_tags = current_tag_frame || @tags
      keys.each do |key|
        if current_tags.equal?(@tags)
          current_tags.delete(key)
        else
          current_tags[key] = nil
        end
      end
    end

    protected

    # used internally by exception() and TraceLogger
    def tag_trace_location(location)
      tag code_file: location.path,
          code_line: location.lineno,
          code_func: location.label
    end

    def untag_trace_location
      untag :code_file, :code_line, :code_func
    end

    private

    def with_scoped_tags(tags)
      contexts = Thread.current[TAG_CONTEXTS_THREAD_KEY] ||= {}
      frames = contexts[self] ||= []
      frames << tags
      yield
    ensure
      frames.pop
      contexts.delete(self) if frames.empty?
      Thread.current[TAG_CONTEXTS_THREAD_KEY] = nil if contexts.empty?
    end

    def current_tag_frame
      contexts = Thread.current[TAG_CONTEXTS_THREAD_KEY]
      frames = contexts && contexts[self]
      frames && frames.last
    end

    def scoped_tag_values
      contexts = Thread.current[TAG_CONTEXTS_THREAD_KEY]
      frames = contexts && contexts[self]
      return {} unless frames

      frames.each_with_object({}) { |frame, values| values.merge!(frame) }
    end

    def real_send(hash)
      hash = hash.delete_if { |_, v| v.nil? }

      array_to_send = hash.map do |k, v|
        key = k.to_s.upcase
        value = v.to_s

        if key == "PRIORITY"
          priority = value.to_i

          return 0 if priority > @min_priority # DEBUG = 7, ALERT = 1
        end

        "#{key}=#{value}"
      end

      @logger.send(*array_to_send)
    end
  end
end
