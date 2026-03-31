require "rails_helper"

RSpec.describe Newsletter, type: :model do
  describe "associations" do
    it "has many newsletter_articles" do
      newsletter = create(:newsletter)
      article = create(:article)
      create(:newsletter_article, newsletter: newsletter, article: article)

      expect(newsletter.newsletter_articles.count).to eq(1)
    end

    it "has many articles through newsletter_articles" do
      newsletter = create(:newsletter)
      article = create(:article)
      create(:newsletter_article, newsletter: newsletter, article: article)

      expect(newsletter.articles).to include(article)
    end

    it "destroys newsletter_articles when destroyed" do
      newsletter = create(:newsletter)
      article = create(:article)
      create(:newsletter_article, newsletter: newsletter, article: article)

      expect { newsletter.destroy }.to change(NewsletterArticle, :count).by(-1)
    end
  end

  describe "validations" do
    it "requires title" do
      newsletter = build(:newsletter, title: nil)
      expect(newsletter).not_to be_valid
      expect(newsletter.errors[:title]).to include("can't be blank")
    end

    it "requires slug" do
      newsletter = build(:newsletter, title: "Test", slug: nil)
      newsletter.valid?
      # Slug gets auto-generated from title
      expect(newsletter.slug).to eq("test")
    end

    it "requires unique slug" do
      create(:newsletter, slug: "my-newsletter")
      newsletter = build(:newsletter, slug: "my-newsletter")
      expect(newsletter).not_to be_valid
      expect(newsletter.errors[:slug]).to include("has already been taken")
    end

    describe "slug format" do
      it "allows lowercase letters and hyphens" do
        newsletter = build(:newsletter, slug: "weekly-digest-42")
        expect(newsletter).to be_valid
      end

      it "does not allow uppercase letters" do
        newsletter = build(:newsletter, slug: "Weekly-Digest")
        expect(newsletter).not_to be_valid
        expect(newsletter.errors[:slug]).to include("must be lowercase with hyphens only")
      end

      it "does not allow spaces" do
        newsletter = build(:newsletter, slug: "weekly digest")
        expect(newsletter).not_to be_valid
      end

      it "does not allow underscores" do
        newsletter = build(:newsletter, slug: "weekly_digest")
        expect(newsletter).not_to be_valid
      end
    end
  end

  describe "slug generation" do
    it "auto-generates slug from title on create" do
      newsletter = create(:newsletter, title: "My First Newsletter", slug: nil)
      expect(newsletter.slug).to eq("my-first-newsletter")
    end

    it "does not overwrite existing slug" do
      newsletter = create(:newsletter, title: "My Newsletter", slug: "custom-slug")
      expect(newsletter.slug).to eq("custom-slug")
    end

    it "handles duplicate slugs by adding counter" do
      create(:newsletter, slug: "weekly-digest")
      newsletter = create(:newsletter, title: "Weekly Digest", slug: nil)
      expect(newsletter.slug).to eq("weekly-digest-1")
    end
  end

  describe "soft delete" do
    it "uses discard for soft deletes" do
      newsletter = create(:newsletter)
      newsletter.discard
      expect(newsletter.discarded_at).to be_present
      expect(Newsletter.kept).not_to include(newsletter)
    end
  end

  describe "#to_param" do
    it "returns the slug" do
      newsletter = create(:newsletter, slug: "weekly-42")
      expect(newsletter.to_param).to eq("weekly-42")
    end
  end

  describe "rich text" do
    it "has a blurb rich text attribute" do
      newsletter = create(:newsletter)
      newsletter.blurb = "Hello **world**"
      newsletter.save!
      expect(newsletter.blurb.to_plain_text).to include("Hello")
    end
  end

  describe "pdf_attachment" do
    it "can have a PDF attached" do
      newsletter = create(:newsletter, :with_pdf)
      expect(newsletter.pdf_attachment).to be_attached
    end

    it "is valid with a PDF file" do
      newsletter = build(:newsletter)
      newsletter.pdf_attachment.attach(
        io: StringIO.new("fake pdf"),
        filename: "test.pdf",
        content_type: "application/pdf"
      )
      expect(newsletter).to be_valid
    end

    it "is invalid with a non-PDF file" do
      newsletter = build(:newsletter)
      newsletter.pdf_attachment.attach(
        io: StringIO.new("fake image"),
        filename: "test.jpg",
        content_type: "image/jpeg"
      )
      expect(newsletter).not_to be_valid
      expect(newsletter.errors[:pdf_attachment]).to include("must be a PDF file")
    end

    it "is invalid when file exceeds 10MB" do
      newsletter = build(:newsletter)
      newsletter.pdf_attachment.attach(
        io: StringIO.new("x" * (11.megabytes)),
        filename: "large.pdf",
        content_type: "application/pdf"
      )
      expect(newsletter).not_to be_valid
      expect(newsletter.errors[:pdf_attachment]).to include("must be less than 10MB")
    end
  end

  describe "cover_image" do
    it "can have a cover image attached" do
      newsletter = create(:newsletter)
      newsletter.cover_image.attach(
        io: StringIO.new("fake image data"),
        filename: "cover.jpg",
        content_type: "image/jpeg"
      )
      expect(newsletter.cover_image).to be_attached
    end
  end

  describe "scopes" do
    describe ".by_recent" do
      it "orders by created_at descending" do
        old = create(:newsletter, created_at: 2.days.ago)
        new = create(:newsletter, created_at: 1.day.ago)

        expect(Newsletter.by_recent).to eq([new, old])
      end
    end

    describe ".sent" do
      it "returns only sent newsletters" do
        sent = create(:newsletter, :sent)
        unsent = create(:newsletter)

        expect(Newsletter.sent).to include(sent)
        expect(Newsletter.sent).not_to include(unsent)
      end
    end

    describe ".not_sent" do
      it "returns only unsent newsletters" do
        sent = create(:newsletter, :sent)
        unsent = create(:newsletter)

        expect(Newsletter.not_sent).not_to include(sent)
        expect(Newsletter.not_sent).to include(unsent)
      end
    end
  end

  describe "#sent?" do
    it "returns false when sent_at is nil" do
      newsletter = build(:newsletter, sent_at: nil)
      expect(newsletter.sent?).to be false
    end

    it "returns true when sent_at is present" do
      newsletter = build(:newsletter, sent_at: Time.current)
      expect(newsletter.sent?).to be true
    end
  end

  describe "#sendable?" do
    it "returns true when published and not sent" do
      newsletter = build(:newsletter, :published, sent_at: nil)
      expect(newsletter.sendable?).to be true
    end

    it "returns false when not published" do
      newsletter = build(:newsletter, :draft)
      expect(newsletter.sendable?).to be false
    end

    it "returns false when already sent" do
      newsletter = build(:newsletter, :published, :sent)
      expect(newsletter.sendable?).to be false
    end
  end

  describe "#mark_as_sent!" do
    it "sets sent_at to current time" do
      newsletter = create(:newsletter, :published)
      freeze_time do
        newsletter.mark_as_sent!
        expect(newsletter.sent_at).to eq(Time.current)
      end
    end
  end
end
