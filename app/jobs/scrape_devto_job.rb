class ScrapeDevtoJob < ApplicationJob
  queue_as :default

  retry_on Scrapable::ScrapingError, wait: :polynomially_longer, attempts: 3

  def perform(limit: 30)
    Rails.logger.info("Starting Dev.to scrape (limit: #{limit})")

    articles = Article.scrape_devto(limit: limit)

    Rails.logger.info("Dev.to scrape complete. Processed #{articles.count} articles.")
  end
end
