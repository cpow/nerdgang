class ScrapeRedditJob < ApplicationJob
  queue_as :default

  retry_on Scrapable::ScrapingError, wait: :polynomially_longer, attempts: 3

  def perform(subreddits: nil)
    subreddits ||= Article::SUBREDDITS

    Rails.logger.info("Starting Reddit scrape for: #{subreddits.join(", ")}")

    articles = Article.scrape_reddit(subreddits: subreddits)

    Rails.logger.info("Reddit scrape complete. Processed #{articles.count} articles.")
  end
end
