module YoutubeSyncable
  extend ActiveSupport::Concern

  class_methods do
    def sync_from_youtube!
      return if youtube_api_key.blank?

      active.find_each(&:sync_recent_videos!)
    end

    def youtube_api_key
      Rails.application.credentials.youtube_api_key
    end
  end

  def sync_recent_videos!
    return if self.class.youtube_api_key.blank?

    items = youtube_search_items
    video_ids = items.map { |item| item.dig("id", "videoId") }.compact
    details_map = youtube_video_details(video_ids)

    items.each do |item|
      snippet = item["snippet"] || {}
      youtube_video_id = item.dig("id", "videoId")
      next if youtube_video_id.blank?

      details = details_map[youtube_video_id] || {}
      stats = details["statistics"] || {}
      content = details["contentDetails"] || {}
      snippet_details = details["snippet"] || {}

      video = creator_videos.find_or_initialize_by(youtube_video_id: youtube_video_id)
      video.assign_attributes(
        title: snippet["title"],
        description: snippet["description"],
        published_at: snippet["publishedAt"],
        tags: snippet_details["tags"] || [],
        duration_seconds: parse_iso8601_duration(content["duration"]),
        view_count: stats["viewCount"].to_i,
        like_count: stats["likeCount"].to_i,
        comment_count: stats["commentCount"].to_i
      )
      video.save!
      video.capture_snapshot!
    end
  end

  private

  def youtube_search_items
    return [] if youtube_channel_id.blank?

    url = URI("https://www.googleapis.com/youtube/v3/search")
    url.query = URI.encode_www_form(
      key: self.class.youtube_api_key,
      channelId: youtube_channel_id,
      part: "snippet",
      order: "date",
      maxResults: 15,
      type: "video"
    )

    response = Net::HTTP.get_response(url)
    return [] unless response.is_a?(Net::HTTPSuccess)

    JSON.parse(response.body).fetch("items", [])
  rescue
    []
  end

  def youtube_video_details(video_ids)
    return {} if video_ids.empty?

    url = URI("https://www.googleapis.com/youtube/v3/videos")
    url.query = URI.encode_www_form(
      key: self.class.youtube_api_key,
      id: video_ids.join(","),
      part: "snippet,statistics,contentDetails"
    )

    response = Net::HTTP.get_response(url)
    return {} unless response.is_a?(Net::HTTPSuccess)

    JSON.parse(response.body).fetch("items", []).index_by { |item| item["id"] }
  rescue
    {}
  end

  def parse_iso8601_duration(duration)
    return 0 if duration.blank?

    match = duration.match(/PT(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?/)
    return 0 unless match

    hours = match[1].to_i
    mins = match[2].to_i
    secs = match[3].to_i
    (hours * 3600) + (mins * 60) + secs
  end
end
