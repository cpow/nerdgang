module IndiehackersScrapable
  extend ActiveSupport::Concern
  include Scrapable

  INDIEHACKERS_BASE = "https://www.indiehackers.com".freeze

  class_methods do
    def scrape_indiehackers(limit: 20)
      Rails.logger.info("Scraping Indie Hackers feed (limit: #{limit})")

      # Indie Hackers exposes a JSON feed for the homepage
      data = fetch_json("#{INDIEHACKERS_BASE}/feed.json")
      posts = data["posts"]&.first(limit) || []

      posts.filter_map do |post|
        next if post["type"] != "post" || post["url"].blank?

        # Handle both internal and external URLs
        url = if post["url"].start_with?("http")
          post["url"]
        else
          "#{INDIEHACKERS_BASE}#{post["url"]}"
        end

        upsert_article(
          source: "indiehackers",
          source_name: "Indie Hackers",
          external_id: post["id"].to_s,
          title: post["title"],
          url: url,
          author: post["user"]&.dig("username"),
          score: post["votesCount"] || 0,
          comments_count: post["commentCount"] || 0,
          published_at: Time.zone.at(post["createdAt"] / 1000)
        )
      rescue Scrapable::ScrapingError => e
        Rails.logger.error("Failed to save Indie Hackers post #{post["id"]}: #{e.message}")
        nil
      end
    end
  end
end
