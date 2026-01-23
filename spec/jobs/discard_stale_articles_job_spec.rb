require "rails_helper"

RSpec.describe DiscardStaleArticlesJob, type: :job do
  describe "#perform" do
    it "discards articles older than 14 days" do
      stale = create(:article, published_at: 15.days.ago)
      recent = create(:article, published_at: 7.days.ago)

      DiscardStaleArticlesJob.new.perform

      expect(stale.reload.discarded?).to be true
      expect(recent.reload.discarded?).to be false
    end

    it "logs the count of discarded articles" do
      create(:article, published_at: 15.days.ago)
      create(:article, published_at: 20.days.ago)

      expect(Rails.logger).to receive(:info).with(/Discarding 2 stale articles/)
      expect(Rails.logger).to receive(:info).with(/discarded successfully/)

      DiscardStaleArticlesJob.new.perform
    end

    it "is enqueued in the default queue" do
      expect(DiscardStaleArticlesJob.new.queue_name).to eq("default")
    end
  end
end
