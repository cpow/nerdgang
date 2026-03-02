require "rails_helper"

RSpec.describe LobstersScrapable do
  describe ".scrape_lobsters", :vcr do
    it "scrapes hottest stories from Lobste.rs" do
      VCR.use_cassette("lobsters_hottest") do
        articles = Article.scrape_lobsters(limit: 5)

        expect(articles).to be_an(Array)
        expect(articles.compact.size).to be > 0

        article = articles.compact.first
        expect(article).to be_a(Article)
        expect(article.source).to eq("lobsters")
        expect(article.source_name).to eq("Lobste.rs")
        expect(article.title).to be_present
        expect(article.url).to be_present
        expect(article.external_id).to be_present
      end
    end

    it "updates existing articles on re-scrape" do
      VCR.use_cassette("lobsters_hottest") do
        Article.scrape_lobsters(limit: 3)
        initial_count = Article.count

        Article.scrape_lobsters(limit: 3)
        expect(Article.count).to eq(initial_count)
      end
    end
  end

  describe "with mocked response" do
    let(:mock_response) do
      [
        {
          "short_id" => "abc123",
          "title" => "Test Article",
          "url" => "https://example.com/article",
          "score" => 42,
          "comment_count" => 10,
          "created_at" => "2024-01-15T10:00:00Z",
          "submitter_user" => "testuser"
        }
      ]
    end

    it "creates articles from Lobste.rs response" do
      allow(Article).to receive(:fetch_json).and_return(mock_response)

      articles = Article.scrape_lobsters(limit: 1)

      expect(articles.size).to eq(1)
      article = articles.first
      expect(article.source).to eq("lobsters")
      expect(article.external_id).to eq("abc123")
      expect(article.title).to eq("Test Article")
      expect(article.author).to eq("testuser")
      expect(article.score).to eq(42)
      expect(article.comments_count).to eq(10)
    end

    it "skips stories without URLs" do
      mock_response.first["url"] = nil
      allow(Article).to receive(:fetch_json).and_return(mock_response)

      articles = Article.scrape_lobsters(limit: 1)

      expect(articles.compact).to be_empty
    end
  end
end
