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
