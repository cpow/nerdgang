class DiscardStaleArticlesJob < ApplicationJob
  queue_as :default

  def perform
    count = Article.stale.count
    Rails.logger.info("Discarding #{count} stale articles (older than 14 days)")

    Article.discard_stale!

    Rails.logger.info("Stale articles discarded successfully")
  end
end
