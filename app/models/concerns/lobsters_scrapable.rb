module LobstersScrapable
  extend ActiveSupport::Concern
  include Scrapable

  LOBSTERS_API_BASE = "https://lobste.rs".freeze

  class_methods do
    def scrape_lobsters(limit: 25)
      Rails.logger.info("Scraping Lobste.rs hottest stories (limit: #{limit})")

      data = fetch_json("#{LOBSTERS_API_BASE}/hottest.json")
      stories = data.first(limit)

      stories.filter_map do |story|
        next if story["url"].blank?

        upsert_article(
          source: "lobsters",
          source_name: "Lobste.rs",
          external_id: story["short_id"],
          title: story["title"],
          url: story["url"],
          author: story["submitter_user"],
          score: story["score"],
          comments_count: story["comment_count"] || 0,
          published_at: Time.zone.parse(story["created_at"])
        )
      rescue Scrapable::ScrapingError => e
        Rails.logger.error("Failed to save Lobste.rs story #{story["short_id"]}: #{e.message}")
        nil
      end
    end
  end
end
