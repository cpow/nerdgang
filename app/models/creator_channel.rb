require "net/http"
require "json"

class CreatorChannel < ApplicationRecord
  include YoutubeSyncable

  serialize :niche_tags, coder: JSON

  has_many :creator_videos, dependent: :destroy
  has_many :ideas, dependent: :nullify

  validates :name, :handle, presence: true
  validates :handle, uniqueness: true

  scope :active, -> { where(active: true) }

  def niche_tags_array
    Array(niche_tags).compact_blank
  end
end
