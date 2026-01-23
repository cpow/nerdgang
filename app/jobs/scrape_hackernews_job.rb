class ScrapeHackernewsJob < ApplicationJob
  queue_as :default

  retry_on Scrapable::ScrapingError, wait: :polynomially_longer, attempts: 3

  def perform(limit: 30)
    Rails.logger.info("Starting Hacker News scrape (limit: #{limit})")

    articles = Article.scrape_hackernews(limit: limit)

    Rails.logger.info("Hacker News scrape complete. Processed #{articles.count} articles.")
  end
end
