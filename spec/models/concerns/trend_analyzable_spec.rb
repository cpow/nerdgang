require "rails_helper"

RSpec.describe TrendAnalyzable do
  it "extracts top keywords from recent videos" do
    channel = create(:creator_channel)
    create(:creator_video, creator_channel: channel, title: "Raspberry Pi robot build", tags: %w[raspberrypi robot])
    create(:creator_video, creator_channel: channel, title: "Raspberry Pi home lab", tags: %w[raspberrypi homelab])

    keywords = CreatorVideo.top_keywords(limit: 5).map(&:first)
    expect(keywords).to include("raspberry")
  end
end
