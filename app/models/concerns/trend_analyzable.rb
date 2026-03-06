module TrendAnalyzable
  extend ActiveSupport::Concern

  class_methods do
    def top_keywords(days: 60, limit: 12)
      where("published_at >= ?", days.days.ago)
        .pluck(:title, :tags)
        .flat_map { |title, tags| extract_tokens(title, tags) }
        .tally
        .sort_by { |_, count| -count }
        .first(limit)
    end

    def high_momentum(days: 30, limit: 15)
      where("published_at >= ?", days.days.ago)
        .order(view_count: :desc)
        .limit(limit)
    end

    def high_velocity(days: 30, limit: 15)
      where("published_at >= ?", days.days.ago)
        .select("creator_videos.*, (view_count * 1.0 / NULLIF(julianday('now') - julianday(published_at), 0)) AS velocity")
        .order(Arel.sql("velocity DESC NULLS LAST"))
        .limit(limit)
    end

    def fastest_growing(days: 7, limit: 15)
      video_ids_with_growth = VideoSnapshot
        .joins(:creator_video)
        .where("video_snapshots.captured_at >= ?", days.days.ago)
        .group(:creator_video_id)
        .having("COUNT(*) >= 2")
        .pluck(:creator_video_id)

      return none if video_ids_with_growth.empty?

      where(id: video_ids_with_growth)
        .order(view_count: :desc)
        .limit(limit)
    end

    def trending(days: 14, limit: 15)
      high_velocity(days: days, limit: limit * 2)
    end

    def extract_tokens(title, tags)
      text = [title, Array(tags).join(" ")].join(" ").downcase
      text.scan(/[a-z0-9+\#]{3,}/).reject do |token|
        %w[the and for with from this that your you into over under build built using use how why what when where after before into make made].include?(token)
      end
    end
  end

  # Instance methods for individual video trend metrics

  def velocity_score
    return 0 if published_at.blank? || view_count.to_i.zero?

    days_since_publish = [(Time.current - published_at) / 1.day, 1].max
    (view_count.to_f / days_since_publish).round(2)
  end

  def growth_rate_7d
    snapshots = video_snapshots.where("captured_at >= ?", 7.days.ago).order(:captured_at)
    return 0.0 if snapshots.count < 2

    oldest = snapshots.first.view_count.to_i
    newest = snapshots.last.view_count.to_i
    return 0.0 if oldest.zero?

    (((newest - oldest).to_f / oldest) * 100).round(2)
  end

  def engagement_rate
    return 0.0 if view_count.to_i.zero?

    engagements = like_count.to_i + comment_count.to_i
    ((engagements.to_f / view_count) * 100).round(4)
  end

  def trend_score
    v_score = [velocity_score / 1000.0, 40].min
    g_score = [growth_rate_7d / 10.0, 30].min
    e_score = [engagement_rate * 5, 30].min

    [v_score + g_score + e_score, 100].min.round
  end
end
