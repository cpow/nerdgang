require "rails_helper"

RSpec.describe SendNewsletterJob, type: :job do
  describe "#perform" do
    let(:newsletter) { create(:newsletter, :published) }

    it "sends emails to all subscribed subscribers" do
      create(:subscriber)
      create(:subscriber)
      create(:subscriber, :unsubscribed)

      expect {
        described_class.new.perform(newsletter.id)
      }.to have_enqueued_mail(NewsletterMailer, :weekly_digest).twice
    end

    it "marks the newsletter as sent" do
      create(:subscriber)

      freeze_time do
        described_class.new.perform(newsletter.id)
        expect(newsletter.reload.sent_at).to eq(Time.current)
      end
    end

    it "does not send if newsletter is already sent" do
      newsletter.update!(sent_at: 1.day.ago)
      create(:subscriber)

      expect {
        described_class.new.perform(newsletter.id)
      }.not_to have_enqueued_mail(NewsletterMailer, :weekly_digest)
    end

    it "does not send if newsletter is not published" do
      draft_newsletter = create(:newsletter, :draft)
      create(:subscriber)

      expect {
        described_class.new.perform(draft_newsletter.id)
      }.not_to have_enqueued_mail(NewsletterMailer, :weekly_digest)
    end

    it "is enqueued in the default queue" do
      expect(described_class.new.queue_name).to eq("default")
    end
  end
end
