class CreatorVideo < ApplicationRecord
  include MetricScorable
  include TrendAnalyzable

  belongs_to :creator_channel
  has_many :video_snapshots, dependent: :destroy
  has_many :ideas, dependent: :nullify

  validates :youtube_video_id, :title, presence: true
  validates :youtube_video_id, uniqueness: true

  scope :recent, -> { order(published_at: :desc) }

  def capture_snapshot!
    video_snapshots.create!(
      captured_at: Time.current,
      view_count: view_count,
      like_count: like_count,
      comment_count: comment_count
    )
  end
end
