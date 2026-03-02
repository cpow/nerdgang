module DevtoScrapable
  extend ActiveSupport::Concern
  include Scrapable

  DEVTO_API_BASE = "https://dev.to/api".freeze

  class_methods do
    def scrape_devto(limit: 30)
      Rails.logger.info("Scraping Dev.to top articles (limit: #{limit})")

      data = fetch_json("#{DEVTO_API_BASE}/articles?per_page=#{limit}&top=7")

      data.filter_map do |article|
        upsert_article(
          source: "devto",
          source_name: "Dev.to",
          external_id: article["id"].to_s,
          title: article["title"],
          url: article["url"],
          author: article["user"]&.dig("username"),
          score: article["public_reactions_count"] || 0,
          comments_count: article["comments_count"] || 0,
          published_at: Time.zone.parse(article["published_at"])
        )
      rescue Scrapable::ScrapingError => e
        Rails.logger.error("Failed to save Dev.to article #{article["id"]}: #{e.message}")
        nil
      end
    end
  end
end
