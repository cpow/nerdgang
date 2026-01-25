require "rails_helper"

RSpec.describe Publishable do
  # Using Newsletter as the model that includes Publishable
  let(:draft_newsletter) { create(:newsletter, :draft) }
  let(:published_newsletter) { create(:newsletter, :published) }

  describe "scopes" do
    describe ".draft" do
      it "returns only unpublished records" do
        expect(Newsletter.draft).to include(draft_newsletter)
        expect(Newsletter.draft).not_to include(published_newsletter)
      end
    end

    describe ".published" do
      it "returns only published records" do
        expect(Newsletter.published).to include(published_newsletter)
        expect(Newsletter.published).not_to include(draft_newsletter)
      end
    end

    describe ".recently_published" do
      it "returns published records ordered by published_at desc" do
        older = create(:newsletter, published_at: 3.days.ago)
        newer = create(:newsletter, published_at: 2.hours.ago)

        result = Newsletter.recently_published.to_a
        expect(result.first).to eq(newer)
        expect(result.last).to eq(older)
      end
    end
  end

  describe "#publish!" do
    it "sets published_at to current time" do
      freeze_time do
        draft_newsletter.publish!
        expect(draft_newsletter.published_at).to eq(Time.current)
      end
    end
  end

  describe "#unpublish!" do
    it "clears published_at" do
      published_newsletter.unpublish!
      expect(published_newsletter.published_at).to be_nil
    end
  end

  describe "#published?" do
    it "returns true when published_at is present" do
      expect(published_newsletter.published?).to be true
    end

    it "returns false when published_at is nil" do
      expect(draft_newsletter.published?).to be false
    end
  end

  describe "#draft?" do
    it "returns true when published_at is nil" do
      expect(draft_newsletter.draft?).to be true
    end

    it "returns false when published_at is present" do
      expect(published_newsletter.draft?).to be false
    end
  end
end
