class Newsletter < ApplicationRecord
  include Discard::Model
  include Publishable

  has_rich_text :blurb
  has_one_attached :cover_image
  has_one_attached :pdf_attachment
  has_many :newsletter_articles, -> { order(position: :asc) }, dependent: :destroy
  has_many :articles, through: :newsletter_articles

  validates :title, presence: true
  validates :slug, presence: true, uniqueness: true,
    format: {with: /\A[a-z0-9]+(?:-[a-z0-9]+)*\z/, message: "must be lowercase with hyphens only"}

  validate :acceptable_pdf_attachment

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

  def acceptable_pdf_attachment
    return unless pdf_attachment.attached?
    unless pdf_attachment.content_type == "application/pdf"
      errors.add(:pdf_attachment, "must be a PDF file")
    end
    if pdf_attachment.byte_size > 10.megabytes
      errors.add(:pdf_attachment, "must be less than 10MB")
    end
  end

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
