require "rails_helper"

RSpec.describe "Newsletters", type: :request do
  describe "GET /newsletters" do
    it "returns success" do
      get newsletters_path
      expect(response).to have_http_status(:success)
    end

    it "displays published newsletters" do
      create(:newsletter, :published, title: "Published Newsletter")
      get newsletters_path

      expect(response.body).to include("Published Newsletter")
    end

    it "does not display draft newsletters" do
      create(:newsletter, :draft, title: "Draft Newsletter")
      get newsletters_path

      expect(response.body).not_to include("Draft Newsletter")
    end

    it "does not display discarded newsletters" do
      create(:newsletter, :published, :discarded, title: "Discarded Newsletter")
      get newsletters_path

      expect(response.body).not_to include("Discarded Newsletter")
    end

    it "orders by most recently published" do
      create(:newsletter, :published, title: "Older Newsletter", published_at: 2.days.ago)
      create(:newsletter, :published, title: "Newer Newsletter", published_at: 1.day.ago)

      get newsletters_path

      expect(response.body.index("Newer Newsletter")).to be < response.body.index("Older Newsletter")
    end
  end

  describe "GET /newsletters/:slug" do
    let(:newsletter) { create(:newsletter, :published, title: "Test Newsletter", slug: "test-newsletter") }

    it "returns success for published newsletters" do
      get newsletter_path(newsletter.slug)
      expect(response).to have_http_status(:success)
    end

    it "displays newsletter content" do
      get newsletter_path(newsletter.slug)
      expect(response.body).to include("Test Newsletter")
    end

    it "displays newsletter articles" do
      article = create(:article, title: "Featured Article")
      create(:newsletter_article, newsletter: newsletter, article: article)

      get newsletter_path(newsletter.slug)
      expect(response.body).to include("Featured Article")
    end

    it "displays article commentary" do
      article = create(:article)
      create(:newsletter_article, newsletter: newsletter, article: article, commentary: "My thoughts on this")

      get newsletter_path(newsletter.slug)
      expect(response.body).to include("My thoughts on this")
    end

    it "returns 404 for draft newsletters" do
      draft = create(:newsletter, :draft, slug: "draft-newsletter")
      get newsletter_path(draft.slug)
      expect(response).to have_http_status(:not_found)
    end

    it "returns 404 for discarded newsletters" do
      discarded = create(:newsletter, :published, :discarded, slug: "discarded-newsletter")
      get newsletter_path(discarded.slug)
      expect(response).to have_http_status(:not_found)
    end

    it "returns 404 for non-existent slugs" do
      get newsletter_path("non-existent")
      expect(response).to have_http_status(:not_found)
    end
  end
end
