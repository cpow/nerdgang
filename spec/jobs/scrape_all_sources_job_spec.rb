require "rails_helper"

RSpec.describe ScrapeAllSourcesJob, type: :job do
  describe "#perform" do
    it "enqueues both Reddit and Hacker News scrape jobs" do
      expect(ScrapeRedditJob).to receive(:perform_later)
      expect(ScrapeHackernewsJob).to receive(:perform_later)

      ScrapeAllSourcesJob.new.perform
    end

    it "is enqueued in the default queue" do
      expect(ScrapeAllSourcesJob.new.queue_name).to eq("default")
    end
  end
end
