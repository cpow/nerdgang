class ScrapeIndiehackersJob < ApplicationJob
  queue_as :default

  retry_on Scrapable::ScrapingError, wait: :polynomially_longer, attempts: 3

  def perform(limit: 20)
    Rails.logger.info("Starting Indie Hackers scrape (limit: #{limit})")

    articles = Article.scrape_indiehackers(limit: limit)

    Rails.logger.info("Indie Hackers scrape complete. Processed #{articles.count} articles.")
  end
end
