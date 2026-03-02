class SyncYoutubeDataJob < ApplicationJob
  queue_as :default

  def perform
    CreatorChannel.sync_from_youtube!
  end
end
