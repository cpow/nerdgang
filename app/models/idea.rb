class Idea < ApplicationRecord
  include IdeaSuggestable

  belongs_to :creator_channel, optional: true
  belongs_to :creator_video, optional: true

  STATUSES = %w[backlog researching scripting filmed published].freeze

  validates :title, presence: true
  validates :status, inclusion: {in: STATUSES}

  scope :backlog, -> { where(status: "backlog") }
end
