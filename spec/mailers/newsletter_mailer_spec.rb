require "rails_helper"

RSpec.describe NewsletterMailer, type: :mailer do
  describe "#weekly_digest" do
    let(:subscriber) { create(:subscriber) }
    let(:newsletter) { create(:newsletter, :published, title: "Weekly Digest #42") }
    let(:article) { create(:article, :from_hackernews, title: "Great Article", score: 100, comments_count: 50) }
    let(:mail) { described_class.weekly_digest(subscriber, newsletter) }

    before do
      create(:newsletter_article, newsletter: newsletter, article: article, commentary: "This is great!")
    end

    it "renders the headers" do
      expect(mail.subject).to eq("Weekly Digest #42")
      expect(mail.to).to eq([subscriber.email])
      expect(mail.from).to eq(["chris@chrispower.dev"])
    end

    it "renders the HTML body" do
      expect(mail.html_part.body.to_s).to include("Weekly Digest #42")
      expect(mail.html_part.body.to_s).to include("Great Article")
      expect(mail.html_part.body.to_s).to include("This is great!")
    end

    it "renders the plain text body" do
      expect(mail.text_part.body.to_s).to include("Weekly Digest #42")
      expect(mail.text_part.body.to_s).to include("Great Article")
      expect(mail.text_part.body.to_s).to include("This is great!")
    end

    it "includes the unsubscribe link" do
      expect(mail.html_part.body.to_s).to include(subscriber.unsubscribe_token)
      expect(mail.text_part.body.to_s).to include(subscriber.unsubscribe_token)
    end

    it "includes article metadata" do
      expect(mail.html_part.body.to_s).to include("100 points")
      expect(mail.html_part.body.to_s).to include("50 comments")
    end

    it "includes the newsletter blurb when present" do
      newsletter.blurb = "This week in tech..."
      newsletter.save!

      new_mail = described_class.weekly_digest(subscriber, newsletter)
      expect(new_mail.html_part.body.to_s).to include("This week in tech...")
      expect(new_mail.text_part.body.to_s).to include("This week in tech...")
    end
  end

  describe "#welcome" do
    let(:subscriber) { create(:subscriber) }
    let(:mail) { described_class.welcome(subscriber) }

    it "renders the headers" do
      expect(mail.subject).to include("Welcome to NerdGang")
      expect(mail.to).to eq([subscriber.email])
      expect(mail.from).to eq(["chris@chrispower.dev"])
    end

    it "renders the HTML body" do
      expect(mail.html_part.body.to_s).to include("You're in")
      expect(mail.html_part.body.to_s).to include("pretty good")
      expect(mail.html_part.body.to_s).to include("Browse the Archive")
    end

    it "renders the plain text body" do
      expect(mail.text_part.body.to_s).to include("You're in")
      expect(mail.text_part.body.to_s).to include("pretty good")
    end

    it "includes the unsubscribe link" do
      expect(mail.html_part.body.to_s).to include(subscriber.unsubscribe_token)
      expect(mail.text_part.body.to_s).to include(subscriber.unsubscribe_token)
    end
  end
end
