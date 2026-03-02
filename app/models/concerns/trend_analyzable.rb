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

    def extract_tokens(title, tags)
      text = [title, Array(tags).join(" ")].join(" ").downcase
      text.scan(/[a-z0-9+\#]{3,}/).reject do |token|
        %w[the and for with from this that your you into over under build built using use how why what when where after before into make made].include?(token)
      end
    end
  end
end
