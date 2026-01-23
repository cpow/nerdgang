require "rails_helper"

RSpec.describe ScrapeRedditJob, type: :job do
  describe "#perform" do
    it "calls Article.scrape_reddit with default subreddits" do
      expect(Article).to receive(:scrape_reddit).with(subreddits: Article::SUBREDDITS).and_return([])

      ScrapeRedditJob.new.perform
    end

    it "calls Article.scrape_reddit with custom subreddits" do
      custom_subreddits = ["ruby", "rails"]
      expect(Article).to receive(:scrape_reddit).with(subreddits: custom_subreddits).and_return([])

      ScrapeRedditJob.new.perform(subreddits: custom_subreddits)
    end

    it "is enqueued in the default queue" do
      expect(ScrapeRedditJob.new.queue_name).to eq("default")
    end

    it "logs info about the scrape" do
      allow(Article).to receive(:scrape_reddit).and_return([build(:article)])
      expect(Rails.logger).to receive(:info).at_least(:twice)

      ScrapeRedditJob.new.perform
    end
  end
end
