require "spec_helper"

RSpec.describe Journald::Logger do
  describe "acts as logger" do
    before(:each) do
      allow(Journald::Native).to receive(:send).and_return(0)
      @logger = Journald::Logger.new("rspec journald-logger", Journald::LOG_DEBUG)
    end

    it "logs things as logger" do
      # todo: expects
      @logger.warn "test warn"
    end

    it "logs things as syslog" do
      # todo: expects
      @logger.log_warning "test log_warning"
    end

    it "adds tags" do
      @logger.tag(tag1: "value1")
      @logger.tag(tag2: "value2")

      expect(@logger.tag_value(:tag1)).to eq("value1")

      @logger.tag(tag1: "in-block-value") do
        expect(@logger.tag_value(:tag1)).to eq("in-block-value")
      end

      expect(@logger.tag_value(:tag1)).to eq("value1") # expect old value to be restored
    end

    it "keeps block tags isolated between threads" do
      messages = Queue.new
      entered_tag_block = Queue.new
      continue_tag_block = Queue.new
      allow(Journald::Native).to receive(:send) do |*fields|
        messages << fields
        0
      end

      @logger.tag(request_id: "global")
      thread = Thread.new do
        @logger.tag(request_id: "thread") do
          entered_tag_block << true
          continue_tag_block.pop
          @logger.info("inside")
        end
      end

      entered_tag_block.pop
      @logger.info("outside")
      continue_tag_block << true
      thread.join

      outside_message = messages.pop
      inside_message = messages.pop
      expect(outside_message).to include("REQUEST_ID=global")
      expect(outside_message).not_to include("REQUEST_ID=thread")
      expect(inside_message).to include("REQUEST_ID=thread")
    end

    it "does not evaluate filtered message blocks" do
      evaluated = false
      @logger.min_priority = Journald::LOG_ERR

      @logger.debug do
        evaluated = true
        "filtered"
      end

      expect(evaluated).to be(false)
      expect(Journald::Native).not_to have_received(:send)
    end

    it "logs exceptions" do
      # todo: expects
      begin
        raise "logs exception"
      rescue => e
        @logger.exception e
      end
    end
  end
end

RSpec.describe Journald::TraceLogger do
  it "yields the trace wrapper from tag and silence blocks" do
    messages = Queue.new
    allow(Journald::Native).to receive(:send) do |*fields|
      messages << fields
      0
    end

    logger = described_class.new("rspec trace logger", Journald::LOG_DEBUG)
    tag_block_logger = nil
    logger.tag(scope: "tag") do |block_logger|
      tag_block_logger = block_logger
      block_logger.info("tagged")
    end

    silence_block_logger = nil
    logger.silence(Logger::DEBUG) do |block_logger|
      silence_block_logger = block_logger
      block_logger.info("silenced")
    end

    expect(tag_block_logger).to equal(logger)
    expect(silence_block_logger).to equal(logger)

    tag_message = messages.pop
    silence_message = messages.pop
    expect(tag_message).to include("SCOPE=tag")
    [tag_message, silence_message].each do |fields|
      expect(fields.grep(/\ACODE_FILE=/)).not_to be_empty
    end
  end
end
