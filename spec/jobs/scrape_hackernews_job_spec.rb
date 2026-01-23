require "rails_helper"

RSpec.describe ScrapeHackernewsJob, type: :job do
  describe "#perform" do
    it "calls Article.scrape_hackernews with default limit" do
      expect(Article).to receive(:scrape_hackernews).with(limit: 30).and_return([])

      ScrapeHackernewsJob.new.perform
    end

    it "calls Article.scrape_hackernews with custom limit" do
      expect(Article).to receive(:scrape_hackernews).with(limit: 50).and_return([])

      ScrapeHackernewsJob.new.perform(limit: 50)
    end

    it "is enqueued in the default queue" do
      expect(ScrapeHackernewsJob.new.queue_name).to eq("default")
    end

    it "logs info about the scrape" do
      allow(Article).to receive(:scrape_hackernews).and_return([build(:article)])
      expect(Rails.logger).to receive(:info).at_least(:twice)

      ScrapeHackernewsJob.new.perform
    end
  end
end
