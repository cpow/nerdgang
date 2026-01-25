module Publishable
  extend ActiveSupport::Concern

  included do
    scope :draft, -> { where(published_at: nil) }
    scope :published, -> { where.not(published_at: nil) }
    scope :recently_published, -> { published.order(published_at: :desc) }
  end

  def publish!
    update!(published_at: Time.current)
  end

  def unpublish!
    update!(published_at: nil)
  end

  def published?
    published_at.present?
  end

  def draft?
    published_at.nil?
  end
end
