class VideoSnapshot < ApplicationRecord
  belongs_to :creator_video

  validates :captured_at, presence: true
end
