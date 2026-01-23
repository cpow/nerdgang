require "rails_helper"

RSpec.describe Scrapable do
  describe ".fetch_json" do
    it "fetches and parses JSON from a URL", :vcr do
      VCR.use_cassette("hackernews_topstories") do
        result = Article.fetch_json("https://hacker-news.firebaseio.com/v0/topstories.json")
        expect(result).to be_an(Array)
        expect(result.first).to be_a(Integer)
      end
    end

    it "raises ScrapingError on HTTP errors" do
      VCR.use_cassette("http_error") do
        stub_request(:get, "https://example.com/404")
          .to_return(status: 404, body: "Not Found")

        expect {
          Article.fetch_json("https://example.com/404")
        }.to raise_error(Scrapable::ScrapingError, /HTTP 404/)
      end
    end

    it "raises ScrapingError on invalid JSON" do
      VCR.use_cassette("invalid_json") do
        stub_request(:get, "https://example.com/invalid")
          .to_return(status: 200, body: "not json")

        expect {
          Article.fetch_json("https://example.com/invalid")
        }.to raise_error(Scrapable::ScrapingError, /Invalid JSON/)
      end
    end

    it "raises ScrapingError on timeout" do
      stub_request(:get, "https://example.com/slow")
        .to_timeout

      expect {
        Article.fetch_json("https://example.com/slow")
      }.to raise_error(Scrapable::ScrapingError, /timeout/i)
    end
  end

  describe ".upsert_article" do
    it "creates a new article" do
      expect {
        Article.upsert_article(
          source: "reddit",
          external_id: "new123",
          title: "New Article",
          url: "https://example.com/new",
          score: 100,
          comments_count: 10,
          published_at: 1.hour.ago
        )
      }.to change(Article, :count).by(1)
    end

    it "updates an existing article" do
      article = create(:article, source: "reddit", external_id: "existing123", score: 50)

      expect {
        Article.upsert_article(
          source: "reddit",
          external_id: "existing123",
          title: article.title,
          url: article.url,
          score: 200,
          comments_count: 50,
          published_at: article.published_at
        )
      }.not_to change(Article, :count)

      expect(article.reload.score).to eq(200)
    end

    it "updates scraped_at on upsert" do
      freeze_time do
        Article.upsert_article(
          source: "reddit",
          external_id: "time123",
          title: "Test",
          url: "https://example.com",
          score: 10,
          comments_count: 1,
          published_at: 1.hour.ago
        )

        expect(Article.last.scraped_at).to eq(Time.current)
      end
    end

    it "returns nil on validation error" do
      result = Article.upsert_article(
        source: "invalid_source",
        external_id: "bad",
        title: "Test",
        url: "https://example.com",
        score: 10,
        comments_count: 1,
        published_at: 1.hour.ago
      )

      expect(result).to be_nil
    end
  end
end
