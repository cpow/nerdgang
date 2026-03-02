require "rails_helper"

RSpec.describe IndiehackersScrapable do
  # Note: VCR tests skipped as Indie Hackers feed.json endpoint may redirect
  # The mocked tests below verify the scraping logic

  describe "with mocked response" do
    let(:mock_response) do
      {
        "posts" => [
          {
            "id" => "post123",
            "type" => "post",
            "title" => "How I Built My SaaS",
            "url" => "/post/how-i-built-my-saas",
            "votesCount" => 85,
            "commentCount" => 32,
            "createdAt" => 1705320000000,
            "user" => {"username" => "ihuser"}
          }
        ]
      }
    end

    it "creates articles from Indie Hackers response" do
      allow(Article).to receive(:fetch_json).and_return(mock_response)

      articles = Article.scrape_indiehackers(limit: 1)

      expect(articles.size).to eq(1)
      article = articles.first
      expect(article.source).to eq("indiehackers")
      expect(article.external_id).to eq("post123")
      expect(article.title).to eq("How I Built My SaaS")
      expect(article.author).to eq("ihuser")
      expect(article.score).to eq(85)
      expect(article.comments_count).to eq(32)
      expect(article.url).to eq("https://www.indiehackers.com/post/how-i-built-my-saas")
    end

    it "handles external URLs correctly" do
      mock_response["posts"].first["url"] = "https://external-site.com/article"
      allow(Article).to receive(:fetch_json).and_return(mock_response)

      articles = Article.scrape_indiehackers(limit: 1)

      expect(articles.first.url).to eq("https://external-site.com/article")
    end

    it "skips non-post types" do
      mock_response["posts"].first["type"] = "comment"
      allow(Article).to receive(:fetch_json).and_return(mock_response)

      articles = Article.scrape_indiehackers(limit: 1)

      expect(articles.compact).to be_empty
    end

    it "skips posts without URLs" do
      mock_response["posts"].first["url"] = nil
      allow(Article).to receive(:fetch_json).and_return(mock_response)

      articles = Article.scrape_indiehackers(limit: 1)

      expect(articles.compact).to be_empty
    end
  end
end
