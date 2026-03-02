class ScrapeLobstersJob < ApplicationJob
  queue_as :default

  retry_on Scrapable::ScrapingError, wait: :polynomially_longer, attempts: 3

  def perform(limit: 25)
    Rails.logger.info("Starting Lobste.rs scrape (limit: #{limit})")

    articles = Article.scrape_lobsters(limit: limit)

    Rails.logger.info("Lobste.rs scrape complete. Processed #{articles.count} articles.")
  end
end
