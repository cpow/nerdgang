module HackernewsScrapable
  extend ActiveSupport::Concern
  include Scrapable

  HN_API_BASE = "https://hacker-news.firebaseio.com/v0".freeze

  class_methods do
    def scrape_hackernews(limit: 30)
      top_ids = fetch_json("#{HN_API_BASE}/topstories.json")
      story_ids = top_ids.first(limit)

      story_ids.filter_map do |story_id|
        scrape_hn_story(story_id)
      rescue Scrapable::ScrapingError => e
        Rails.logger.error("Failed to scrape HN story #{story_id}: #{e.message}")
        nil
      end
    end

    def scrape_hn_story(story_id)
      story = fetch_json("#{HN_API_BASE}/item/#{story_id}.json")

      return nil if story["type"] != "story" || story["url"].blank?

      upsert_article(
        source: "hackernews",
        source_name: "Hacker News",
        external_id: story["id"].to_s,
        title: story["title"],
        url: story["url"],
        author: story["by"],
        score: story["score"],
        comments_count: story["descendants"] || 0,
        published_at: Time.zone.at(story["time"])
      )
    end
  end
end
