require "rails_helper"

RSpec.describe RedditScrapable do
  describe "SUBREDDITS" do
    it "contains expected subreddits" do
      expect(Article::SUBREDDITS).to include("programming", "webdev", "linux", "devops")
    end
  end

  describe ".scrape_subreddit", :vcr do
    it "scrapes articles from a subreddit" do
      VCR.use_cassette("reddit_technology") do
        articles = Article.scrape_subreddit("technology", limit: 5)

        expect(articles).to be_an(Array)
        expect(articles.compact.size).to be > 0

        article = articles.compact.first
        expect(article).to be_a(Article)
        expect(article.source).to eq("reddit")
        expect(article.source_name).to eq("technology")
        expect(article.title).to be_present
        expect(article.url).to be_present
        expect(article.external_id).to be_present
      end
    end

    it "skips self posts" do
      VCR.use_cassette("reddit_with_self_posts") do
        # Self posts are filtered out in the scraping logic
        articles = Article.scrape_subreddit("technology", limit: 10)

        articles.compact.each do |article|
          # Self posts would have reddit.com as the domain
          # but our scraper filters them out based on is_self flag
          expect(article.url).not_to match(/^https:\/\/www\.reddit\.com\/r\/.*\/comments/)
        end
      end
    end

    it "updates existing articles on re-scrape" do
      VCR.use_cassette("reddit_technology") do
        # First scrape
        Article.scrape_subreddit("technology", limit: 3)
        initial_count = Article.count

        # Second scrape should not create duplicates
        Article.scrape_subreddit("technology", limit: 3)
        expect(Article.count).to eq(initial_count)
      end
    end
  end

  describe ".scrape_reddit", :vcr do
    it "scrapes from multiple subreddits" do
      VCR.use_cassette("reddit_multiple_subreddits") do
        articles = Article.scrape_reddit(subreddits: ["technology", "programming"], limit: 3)

        expect(articles).to be_an(Array)
        sources = articles.compact.map(&:source_name).uniq
        expect(sources).to include("technology")
      end
    end

    it "continues on error for a single subreddit" do
      VCR.use_cassette("reddit_with_error") do
        # Mock one subreddit to fail
        allow(Article).to receive(:scrape_subreddit).with("nonexistent", limit: 3).and_raise(Scrapable::ScrapingError)
        allow(Article).to receive(:scrape_subreddit).with("technology", limit: 3).and_call_original

        articles = Article.scrape_reddit(subreddits: ["nonexistent", "technology"], limit: 3)

        # Should still return articles from technology
        expect(articles.flatten.compact).not_to be_empty
      end
    end
  end
end
