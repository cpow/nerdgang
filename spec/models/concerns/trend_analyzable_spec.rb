require "rails_helper"

RSpec.describe TrendAnalyzable do
  let(:channel) { create(:creator_channel) }

  describe ".top_keywords" do
    it "extracts top keywords from recent videos" do
      create(:creator_video, creator_channel: channel, title: "Raspberry Pi robot build", tags: %w[raspberrypi robot])
      create(:creator_video, creator_channel: channel, title: "Raspberry Pi home lab", tags: %w[raspberrypi homelab])

      keywords = CreatorVideo.top_keywords(limit: 5).map(&:first)
      expect(keywords).to include("raspberry")
    end

    it "excludes common stop words" do
      create(:creator_video, creator_channel: channel, title: "How to build with the best tools", tags: [])

      keywords = CreatorVideo.top_keywords(limit: 10).map(&:first)
      expect(keywords).not_to include("the", "how", "with")
    end
  end

  describe ".high_velocity" do
    it "returns videos sorted by views per day" do
      create(:creator_video, creator_channel: channel, published_at: 30.days.ago, view_count: 100_000)
      new_viral = create(:creator_video, creator_channel: channel, published_at: 1.day.ago, view_count: 50_000)
      create(:creator_video, creator_channel: channel, published_at: 2.days.ago, view_count: 1_000)

      results = CreatorVideo.high_velocity(limit: 3)
      expect(results.first).to eq(new_viral)
    end

    it "limits results" do
      5.times { create(:creator_video, creator_channel: channel) }

      expect(CreatorVideo.high_velocity(limit: 3).to_a.size).to eq(3)
    end
  end

  describe ".fastest_growing" do
    it "returns videos with snapshot growth data" do
      video_with_snapshots = create(:creator_video, creator_channel: channel, view_count: 10_000)
      create(:video_snapshot, creator_video: video_with_snapshots, view_count: 5_000, captured_at: 5.days.ago)
      create(:video_snapshot, creator_video: video_with_snapshots, view_count: 10_000, captured_at: 1.day.ago)

      video_without_snapshots = create(:creator_video, creator_channel: channel, view_count: 50_000)

      results = CreatorVideo.fastest_growing(limit: 5)
      expect(results).to include(video_with_snapshots)
      expect(results).not_to include(video_without_snapshots)
    end

    it "returns empty when no videos have enough snapshots" do
      create(:creator_video, creator_channel: channel)

      expect(CreatorVideo.fastest_growing).to be_empty
    end
  end

  describe "#velocity_score" do
    it "calculates views per day since publish" do
      video = create(:creator_video, published_at: 10.days.ago, view_count: 10_000)

      expect(video.velocity_score).to eq(1000.0)
    end

    it "returns 0 for zero views" do
      video = create(:creator_video, published_at: 1.day.ago, view_count: 0)

      expect(video.velocity_score).to eq(0)
    end

    it "uses minimum of 1 day for very recent videos" do
      video = create(:creator_video, published_at: 1.hour.ago, view_count: 1000)

      expect(video.velocity_score).to eq(1000.0)
    end
  end

  describe "#growth_rate_7d" do
    it "calculates percentage growth from snapshots" do
      video = create(:creator_video, view_count: 2000)
      create(:video_snapshot, creator_video: video, view_count: 1000, captured_at: 5.days.ago)
      create(:video_snapshot, creator_video: video, view_count: 2000, captured_at: 1.day.ago)

      expect(video.growth_rate_7d).to eq(100.0)
    end

    it "returns 0 with insufficient snapshots" do
      video = create(:creator_video)
      create(:video_snapshot, creator_video: video, captured_at: 1.day.ago)

      expect(video.growth_rate_7d).to eq(0.0)
    end

    it "returns 0 when oldest snapshot has zero views" do
      video = create(:creator_video, view_count: 1000)
      create(:video_snapshot, creator_video: video, view_count: 0, captured_at: 5.days.ago)
      create(:video_snapshot, creator_video: video, view_count: 1000, captured_at: 1.day.ago)

      expect(video.growth_rate_7d).to eq(0.0)
    end
  end

  describe "#engagement_rate" do
    it "calculates engagement as percentage of views" do
      video = create(:creator_video, view_count: 10_000, like_count: 500, comment_count: 100)

      expect(video.engagement_rate).to eq(6.0)
    end

    it "returns 0 for zero views" do
      video = create(:creator_video, view_count: 0, like_count: 10, comment_count: 5)

      expect(video.engagement_rate).to eq(0.0)
    end
  end

  describe "#trend_score" do
    it "returns combined score between 0 and 100" do
      video = create(:creator_video, published_at: 5.days.ago, view_count: 50_000, like_count: 2500, comment_count: 250)

      score = video.trend_score
      expect(score).to be_between(0, 100)
    end

    it "returns high score for viral videos" do
      video = create(:creator_video, published_at: 1.day.ago, view_count: 1_000_000, like_count: 50_000, comment_count: 5000)
      create(:video_snapshot, creator_video: video, view_count: 100_000, captured_at: 6.days.ago)
      create(:video_snapshot, creator_video: video, view_count: 1_000_000, captured_at: 1.day.ago)

      expect(video.trend_score).to be >= 90
    end
  end
end
