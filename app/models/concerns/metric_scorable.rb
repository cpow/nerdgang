module MetricScorable
  extend ActiveSupport::Concern

  def engagement_score
    (like_count.to_i * 2) + (comment_count.to_i * 3)
  end

  def traction_score
    view_count.to_i + engagement_score
  end
end
