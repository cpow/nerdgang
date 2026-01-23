require "rails_helper"

RSpec.describe "Admin::Articles", type: :request do
  let(:valid_credentials) do
    ActionController::HttpAuthentication::Basic.encode_credentials("admin", "password")
  end

  let(:headers) { {"HTTP_AUTHORIZATION" => valid_credentials} }

  describe "GET /admin/articles" do
    it "requires authentication" do
      get admin_articles_path
      expect(response).to have_http_status(:unauthorized)
    end

    it "returns success with valid credentials" do
      get admin_articles_path, headers: headers
      expect(response).to have_http_status(:success)
    end

    it "displays articles" do
      create(:article, title: "Test Article Title")
      get admin_articles_path, headers: headers

      expect(response.body).to include("Test Article Title")
    end

    context "with filters" do
      before do
        create(:article, :from_reddit, title: "Reddit Article", score: 500)
        create(:article, :from_hackernews, title: "HN Article", score: 100)
      end

      it "filters by source" do
        get admin_articles_path, params: {source: "reddit"}, headers: headers

        expect(response.body).to include("Reddit Article")
        expect(response.body).not_to include("HN Article")
      end

      it "filters by search query" do
        get admin_articles_path, params: {q: "Reddit"}, headers: headers

        expect(response.body).to include("Reddit Article")
        expect(response.body).not_to include("HN Article")
      end

      it "filters by minimum score" do
        get admin_articles_path, params: {min_score: 200}, headers: headers

        expect(response.body).to include("Reddit Article")
        expect(response.body).not_to include("HN Article")
      end

      it "filters by status (unread)" do
        Article.first.update!(read_at: Time.current)
        get admin_articles_path, params: {status: "unread"}, headers: headers

        expect(response.body).not_to include("Reddit Article")
        expect(response.body).to include("HN Article")
      end
    end

    context "with sorting" do
      before do
        create(:article, title: "Old High Score", score: 1000, published_at: 3.days.ago)
        create(:article, title: "New Low Score", score: 10, published_at: 1.hour.ago)
      end

      it "sorts by recent by default" do
        get admin_articles_path, headers: headers

        expect(response.body.index("New Low Score")).to be < response.body.index("Old High Score")
      end

      it "sorts by score" do
        get admin_articles_path, params: {sort: "score"}, headers: headers

        expect(response.body.index("Old High Score")).to be < response.body.index("New Low Score")
      end
    end
  end

  describe "GET /admin/articles/:id" do
    let(:article) { create(:article) }

    it "requires authentication" do
      get admin_article_path(article)
      expect(response).to have_http_status(:unauthorized)
    end

    it "returns success with valid credentials" do
      get admin_article_path(article), headers: headers
      expect(response).to have_http_status(:success)
    end

    it "marks article as read" do
      expect(article.read?).to be false

      get admin_article_path(article), headers: headers
      expect(article.reload.read?).to be true
    end
  end

  describe "DELETE /admin/articles/:id" do
    let!(:article) { create(:article) }

    it "requires authentication" do
      delete admin_article_path(article)
      expect(response).to have_http_status(:unauthorized)
    end

    it "deletes the article" do
      expect {
        delete admin_article_path(article), headers: headers
      }.to change(Article, :count).by(-1)
    end

    it "redirects to index" do
      delete admin_article_path(article), headers: headers
      expect(response).to redirect_to(admin_articles_path)
    end
  end

  describe "POST /admin/articles/refresh" do
    it "requires authentication" do
      post refresh_admin_articles_path
      expect(response).to have_http_status(:unauthorized)
    end

    it "enqueues the scrape job" do
      expect(ScrapeAllSourcesJob).to receive(:perform_later)

      post refresh_admin_articles_path, headers: headers
    end

    it "redirects to index with notice" do
      allow(ScrapeAllSourcesJob).to receive(:perform_later)

      post refresh_admin_articles_path, headers: headers
      expect(response).to redirect_to(admin_articles_path)
      expect(flash[:notice]).to be_present
    end
  end

  describe "POST /admin/articles/:id/toggle_bookmark" do
    let(:article) { create(:article, bookmarked: false) }

    it "toggles bookmark status" do
      post toggle_bookmark_admin_article_path(article), headers: headers

      expect(article.reload.bookmarked?).to be true
    end

    it "redirects back by default" do
      post toggle_bookmark_admin_article_path(article), headers: headers
      expect(response).to redirect_to(admin_articles_path)
    end
  end

  describe "GET /admin/articles/bookmarks" do
    it "requires authentication" do
      get bookmarks_admin_articles_path
      expect(response).to have_http_status(:unauthorized)
    end

    it "shows only bookmarked articles" do
      create(:article, :bookmarked, title: "Bookmarked Article")
      create(:article, title: "Normal Article")

      get bookmarks_admin_articles_path, headers: headers

      expect(response.body).to include("Bookmarked Article")
      expect(response.body).not_to include("Normal Article")
    end
  end
end
