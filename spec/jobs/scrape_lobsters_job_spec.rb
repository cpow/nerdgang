require "rails_helper"

RSpec.describe ScrapeLobstersJob, type: :job do
  describe "#perform" do
    it "calls Article.scrape_lobsters with default limit" do
      expect(Article).to receive(:scrape_lobsters).with(limit: 25).and_return([])

      ScrapeLobstersJob.new.perform
    end

    it "calls Article.scrape_lobsters with custom limit" do
      expect(Article).to receive(:scrape_lobsters).with(limit: 50).and_return([])

      ScrapeLobstersJob.new.perform(limit: 50)
    end

    it "is enqueued in the default queue" do
      expect(ScrapeLobstersJob.new.queue_name).to eq("default")
    end

    it "logs info about the scrape" do
      allow(Article).to receive(:scrape_lobsters).and_return([build(:article)])
      expect(Rails.logger).to receive(:info).at_least(:twice)

      ScrapeLobstersJob.new.perform
    end
  end
end
