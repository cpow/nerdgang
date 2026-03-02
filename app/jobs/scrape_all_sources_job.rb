class ScrapeAllSourcesJob < ApplicationJob
  queue_as :default

  def perform
    ScrapeRedditJob.perform_later
    ScrapeHackernewsJob.perform_later
    ScrapeLobstersJob.perform_later
    ScrapeDevtoJob.perform_later
    ScrapeIndiehackersJob.perform_later
  end
end
