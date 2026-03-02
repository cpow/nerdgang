require "rails_helper"

RSpec.describe ScrapeDevtoJob, type: :job do
  describe "#perform" do
    it "calls Article.scrape_devto with default limit" do
      expect(Article).to receive(:scrape_devto).with(limit: 30).and_return([])

      ScrapeDevtoJob.new.perform
    end

    it "calls Article.scrape_devto with custom limit" do
      expect(Article).to receive(:scrape_devto).with(limit: 50).and_return([])

      ScrapeDevtoJob.new.perform(limit: 50)
    end

    it "is enqueued in the default queue" do
      expect(ScrapeDevtoJob.new.queue_name).to eq("default")
    end

    it "logs info about the scrape" do
      allow(Article).to receive(:scrape_devto).and_return([build(:article)])
      expect(Rails.logger).to receive(:info).at_least(:twice)

      ScrapeDevtoJob.new.perform
    end
  end
end
