class NewsletterArticle < ApplicationRecord
  belongs_to :newsletter
  belongs_to :article

  validates :newsletter_id, uniqueness: {scope: :article_id, message: "article already added to this newsletter"}

  before_create :set_position

  def move_up
    return if position <= 1

    swap_with = newsletter.newsletter_articles.find_by(position: position - 1)
    return unless swap_with

    transaction do
      swap_with.update!(position: position)
      update!(position: position - 1)
    end
  end

  def move_down
    max_position = newsletter.newsletter_articles.maximum(:position)
    return if position >= max_position

    swap_with = newsletter.newsletter_articles.find_by(position: position + 1)
    return unless swap_with

    transaction do
      swap_with.update!(position: position)
      update!(position: position + 1)
    end
  end

  private

  def set_position
    return if position.present?
    max = newsletter.newsletter_articles.maximum(:position) || 0
    self.position = max + 1
  end
end
