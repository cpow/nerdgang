class ScrapeAllSourcesJob < ApplicationJob
  queue_as :default

  def perform
    ScrapeRedditJob.perform_later
    ScrapeHackernewsJob.perform_later
  end
end
