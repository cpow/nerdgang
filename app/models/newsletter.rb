class Newsletter < ApplicationRecord
  include Discard::Model
  include Publishable

  has_rich_text :blurb
  has_one_attached :cover_image
  has_many :newsletter_articles, -> { order(position: :asc) }, dependent: :destroy
  has_many :articles, through: :newsletter_articles

  validates :title, presence: true
  validates :slug, presence: true, uniqueness: true,
    format: {with: /\A[a-z0-9]+(?:-[a-z0-9]+)*\z/, message: "must be lowercase with hyphens only"}

  before_validation :generate_slug, on: :create

  scope :by_recent, -> { order(created_at: :desc) }
  scope :sent, -> { where.not(sent_at: nil) }
  scope :not_sent, -> { where(sent_at: nil) }

  def sent?
    sent_at.present?
  end

  def sendable?
    published? && !sent?
  end

  def mark_as_sent!
    update!(sent_at: Time.current)
  end

  def to_param
    slug
  end

  private

  def generate_slug
    return if slug.present?
    return if title.blank?

    base_slug = title.parameterize
    self.slug = base_slug
    counter = 1

    while Newsletter.exists?(slug: slug)
      self.slug = "#{base_slug}-#{counter}"
      counter += 1
    end
  end
end
