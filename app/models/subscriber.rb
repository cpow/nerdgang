class Subscriber < ApplicationRecord
  include Discard::Model

  default_scope -> { kept }

  validates :email, presence: true,
    uniqueness: {case_sensitive: false},
    format: {with: URI::MailTo::EMAIL_REGEXP}

  before_create :generate_unsubscribe_token

  scope :subscribed, -> { where(unsubscribed_at: nil) }
  scope :unsubscribed, -> { where.not(unsubscribed_at: nil) }

  def subscribed?
    unsubscribed_at.nil?
  end

  def unsubscribed?
    unsubscribed_at.present?
  end

  def unsubscribe!(reason: nil)
    update!(unsubscribed_at: Time.current, unsubscribe_reason: reason)
  end

  def resubscribe!
    update!(unsubscribed_at: nil, unsubscribe_reason: nil)
  end

  private

  def generate_unsubscribe_token
    self.unsubscribe_token ||= SecureRandom.urlsafe_base64(32)
  end
end
