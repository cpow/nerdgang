require "rails_helper"

RSpec.describe ScrapeIndiehackersJob, type: :job do
  describe "#perform" do
    it "calls Article.scrape_indiehackers with default limit" do
      expect(Article).to receive(:scrape_indiehackers).with(limit: 20).and_return([])

      ScrapeIndiehackersJob.new.perform
    end

    it "calls Article.scrape_indiehackers with custom limit" do
      expect(Article).to receive(:scrape_indiehackers).with(limit: 50).and_return([])

      ScrapeIndiehackersJob.new.perform(limit: 50)
    end

    it "is enqueued in the default queue" do
      expect(ScrapeIndiehackersJob.new.queue_name).to eq("default")
    end

    it "logs info about the scrape" do
      allow(Article).to receive(:scrape_indiehackers).and_return([build(:article)])
      expect(Rails.logger).to receive(:info).at_least(:twice)

      ScrapeIndiehackersJob.new.perform
    end
  end
end
