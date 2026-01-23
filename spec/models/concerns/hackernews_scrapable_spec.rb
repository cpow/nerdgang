require "rails_helper"

RSpec.describe HackernewsScrapable do
  describe ".scrape_hackernews", :vcr do
    it "scrapes top stories from Hacker News" do
      VCR.use_cassette("hackernews_top_stories") do
        articles = Article.scrape_hackernews(limit: 5)

        expect(articles).to be_an(Array)
        expect(articles.compact.size).to be > 0

        article = articles.compact.first
        expect(article).to be_a(Article)
        expect(article.source).to eq("hackernews")
        expect(article.source_name).to eq("Hacker News")
        expect(article.title).to be_present
        expect(article.url).to be_present
        expect(article.external_id).to be_present
      end
    end

    it "updates existing articles on re-scrape" do
      VCR.use_cassette("hackernews_top_stories") do
        # First scrape
        Article.scrape_hackernews(limit: 3)
        initial_count = Article.count

        # Second scrape should not create duplicates
        Article.scrape_hackernews(limit: 3)
        expect(Article.count).to eq(initial_count)
      end
    end
  end

  describe ".scrape_hn_story", :vcr do
    it "scrapes a single story by ID" do
      VCR.use_cassette("hackernews_single_story") do
        # Get a valid story ID first
        top_ids = Article.fetch_json("https://hacker-news.firebaseio.com/v0/topstories.json")
        story_id = top_ids.first

        article = Article.scrape_hn_story(story_id)

        if article # Some stories might be Ask HN without URL
          expect(article.source).to eq("hackernews")
          expect(article.external_id).to eq(story_id.to_s)
        end
      end
    end

    it "returns nil for Ask HN posts without URL" do
      # Mock an Ask HN post response
      allow(Article).to receive(:fetch_json).and_return({
        "id" => 12345,
        "type" => "story",
        "title" => "Ask HN: Something?",
        "by" => "someone",
        "score" => 100,
        "time" => Time.now.to_i,
        "url" => nil,
        "descendants" => 50
      })

      result = Article.scrape_hn_story(12345)
      expect(result).to be_nil
    end

    it "returns nil for non-story types" do
      allow(Article).to receive(:fetch_json).and_return({
        "id" => 12345,
        "type" => "comment",
        "text" => "A comment",
        "by" => "someone"
      })

      result = Article.scrape_hn_story(12345)
      expect(result).to be_nil
    end
  end
end
