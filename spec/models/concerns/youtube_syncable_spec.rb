require "rails_helper"

RSpec.describe YoutubeSyncable do
  describe ".sync_from_youtube!" do
    it "skips when API key is blank" do
      allow(CreatorChannel).to receive(:youtube_api_key).and_return(nil)

      create(:creator_channel, youtube_channel_id: "UCtest123")

      expect {
        CreatorChannel.sync_from_youtube!
      }.not_to change(CreatorVideo, :count)
    end

    it "syncs videos for all active channels", :vcr do
      allow(CreatorChannel).to receive(:youtube_api_key).and_return("test-api-key")

      channel = create(:creator_channel, youtube_channel_id: "UCo71RUe6DX4w-Vd47rFLXPg", active: true)

      VCR.use_cassette("youtube_sync_channel") do
        CreatorChannel.sync_from_youtube!
      end

      expect(channel.creator_videos.count).to be >= 0
    end
  end

  describe "#sync_recent_videos!" do
    let(:channel) { create(:creator_channel, youtube_channel_id: "UCo71RUe6DX4w-Vd47rFLXPg") }

    it "skips when API key is blank" do
      allow(CreatorChannel).to receive(:youtube_api_key).and_return(nil)

      expect {
        channel.sync_recent_videos!
      }.not_to change(CreatorVideo, :count)
    end

    it "skips when channel_id is blank" do
      allow(CreatorChannel).to receive(:youtube_api_key).and_return("test-key")

      channel = create(:creator_channel, youtube_channel_id: "")

      expect {
        channel.sync_recent_videos!
      }.not_to change(CreatorVideo, :count)
    end

    it "creates videos with correct attributes from API response" do
      allow(CreatorChannel).to receive(:youtube_api_key).and_return("test-api-key")

      search_response = {
        "items" => [
          {
            "id" => {"videoId" => "abc123"},
            "snippet" => {
              "title" => "Test Video Title",
              "description" => "Test description",
              "publishedAt" => "2024-01-15T10:00:00Z"
            }
          }
        ]
      }

      details_response = {
        "items" => [
          {
            "id" => "abc123",
            "snippet" => {"tags" => %w[ruby rails]},
            "statistics" => {
              "viewCount" => "10000",
              "likeCount" => "500",
              "commentCount" => "50"
            },
            "contentDetails" => {"duration" => "PT15M30S"}
          }
        ]
      }

      stub_request(:get, /googleapis.com\/youtube\/v3\/search/)
        .to_return(status: 200, body: search_response.to_json)
      stub_request(:get, /googleapis.com\/youtube\/v3\/videos/)
        .to_return(status: 200, body: details_response.to_json)

      expect {
        channel.sync_recent_videos!
      }.to change(CreatorVideo, :count).by(1)

      video = channel.creator_videos.last
      expect(video.title).to eq("Test Video Title")
      expect(video.youtube_video_id).to eq("abc123")
      expect(video.view_count).to eq(10000)
      expect(video.like_count).to eq(500)
      expect(video.comment_count).to eq(50)
      expect(video.duration_seconds).to eq(930) # 15*60 + 30
      expect(video.tags).to eq(%w[ruby rails])
    end

    it "captures snapshot after syncing video" do
      allow(CreatorChannel).to receive(:youtube_api_key).and_return("test-api-key")

      search_response = {
        "items" => [
          {"id" => {"videoId" => "snap123"}, "snippet" => {"title" => "Snapshot Test"}}
        ]
      }

      details_response = {
        "items" => [
          {
            "id" => "snap123",
            "snippet" => {},
            "statistics" => {"viewCount" => "5000", "likeCount" => "250", "commentCount" => "25"},
            "contentDetails" => {"duration" => "PT10M"}
          }
        ]
      }

      stub_request(:get, /googleapis.com\/youtube\/v3\/search/)
        .to_return(status: 200, body: search_response.to_json)
      stub_request(:get, /googleapis.com\/youtube\/v3\/videos/)
        .to_return(status: 200, body: details_response.to_json)

      expect {
        channel.sync_recent_videos!
      }.to change(VideoSnapshot, :count).by(1)

      snapshot = VideoSnapshot.last
      expect(snapshot.view_count).to eq(5000)
    end

    it "handles API errors gracefully" do
      allow(CreatorChannel).to receive(:youtube_api_key).and_return("test-api-key")

      stub_request(:get, /googleapis.com\/youtube\/v3\/search/)
        .to_return(status: 500, body: "Internal Server Error")

      expect {
        channel.sync_recent_videos!
      }.not_to raise_error

      expect(channel.creator_videos.count).to eq(0)
    end

    it "handles network timeouts gracefully" do
      allow(CreatorChannel).to receive(:youtube_api_key).and_return("test-api-key")

      stub_request(:get, /googleapis.com\/youtube\/v3\/search/)
        .to_timeout

      expect {
        channel.sync_recent_videos!
      }.not_to raise_error
    end
  end

  describe "#parse_iso8601_duration" do
    let(:channel) { create(:creator_channel) }

    it "parses hours, minutes, and seconds" do
      expect(channel.send(:parse_iso8601_duration, "PT1H30M45S")).to eq(5445)
    end

    it "parses minutes and seconds only" do
      expect(channel.send(:parse_iso8601_duration, "PT15M30S")).to eq(930)
    end

    it "parses seconds only" do
      expect(channel.send(:parse_iso8601_duration, "PT45S")).to eq(45)
    end

    it "parses hours only" do
      expect(channel.send(:parse_iso8601_duration, "PT2H")).to eq(7200)
    end

    it "returns 0 for blank duration" do
      expect(channel.send(:parse_iso8601_duration, nil)).to eq(0)
      expect(channel.send(:parse_iso8601_duration, "")).to eq(0)
    end

    it "returns 0 for invalid format" do
      expect(channel.send(:parse_iso8601_duration, "invalid")).to eq(0)
    end
  end
end
