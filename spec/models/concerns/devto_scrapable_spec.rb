require "rails_helper"

RSpec.describe DevtoScrapable do
  describe ".scrape_devto", :vcr do
    it "scrapes top articles from Dev.to" do
      VCR.use_cassette("devto_top_articles") do
        articles = Article.scrape_devto(limit: 5)

        expect(articles).to be_an(Array)
        expect(articles.compact.size).to be > 0

        article = articles.compact.first
        expect(article).to be_a(Article)
        expect(article.source).to eq("devto")
        expect(article.source_name).to eq("Dev.to")
        expect(article.title).to be_present
        expect(article.url).to be_present
        expect(article.external_id).to be_present
      end
    end

    it "updates existing articles on re-scrape" do
      VCR.use_cassette("devto_top_articles") do
        Article.scrape_devto(limit: 3)
        initial_count = Article.count

        Article.scrape_devto(limit: 3)
        expect(Article.count).to eq(initial_count)
      end
    end
  end

  describe "with mocked response" do
    let(:mock_response) do
      [
        {
          "id" => 123456,
          "title" => "How to Build a Rails App",
          "url" => "https://dev.to/user/how-to-build-a-rails-app",
          "public_reactions_count" => 150,
          "comments_count" => 25,
          "published_at" => "2024-01-15T10:00:00Z",
          "user" => {"username" => "devtouser"}
        }
      ]
    end

    it "creates articles from Dev.to response" do
      allow(Article).to receive(:fetch_json).and_return(mock_response)

      articles = Article.scrape_devto(limit: 1)

      expect(articles.size).to eq(1)
      article = articles.first
      expect(article.source).to eq("devto")
      expect(article.external_id).to eq("123456")
      expect(article.title).to eq("How to Build a Rails App")
      expect(article.author).to eq("devtouser")
      expect(article.score).to eq(150)
      expect(article.comments_count).to eq(25)
    end
  end
end
