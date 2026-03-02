class Article < ApplicationRecord
  include Discard::Model
  include RedditScrapable
  include HackernewsScrapable
  include LobstersScrapable
  include DevtoScrapable
  include IndiehackersScrapable

  has_many :newsletter_articles, dependent: :destroy
  has_many :newsletters, through: :newsletter_articles

  # Hide discarded articles by default
  default_scope -> { kept }

  validates :title, presence: true
  validates :url, presence: true
  validates :external_id, presence: true, uniqueness: {scope: :source}
  validates :source, presence: true, inclusion: {in: %w[reddit hackernews lobsters devto indiehackers]}
  validates :scraped_at, presence: true

  # Source scopes
  scope :from_reddit, -> { where(source: "reddit") }
  scope :from_hackernews, -> { where(source: "hackernews") }
  scope :from_lobsters, -> { where(source: "lobsters") }
  scope :from_devto, -> { where(source: "devto") }
  scope :from_indiehackers, -> { where(source: "indiehackers") }

  # Ordering scopes
  scope :recent, -> { order(published_at: :desc) }
  scope :popular, -> { order(score: :desc) }
  scope :by_hot_score, -> { order(Arel.sql("(score + comments_count * 2) / POW(((julianday('now') - julianday(published_at)) * 24) + 2, 1.5) DESC")) }

  # Time filter scopes
  scope :today, -> { where("published_at >= ?", 24.hours.ago) }
  scope :last_3_days, -> { where("published_at >= ?", 3.days.ago) }
  scope :this_week, -> { where("published_at >= ?", 7.days.ago) }

  # Tracking scopes
  scope :bookmarked, -> { where(bookmarked: true) }
  scope :not_bookmarked, -> { where(bookmarked: false) }
  scope :read, -> { where.not(read_at: nil) }
  scope :unread, -> { where(read_at: nil) }

  # Minimum score filter
  scope :min_score, ->(score) { where("score >= ?", score) }

  # Stale articles (older than 14 days)
  scope :stale, -> { where("published_at < ?", 14.days.ago) }

  def self.discard_stale!
    stale.discard_all
  end

  def self.sources
    %w[reddit hackernews lobsters devto indiehackers]
  end

  def reddit?
    source == "reddit"
  end

  def hackernews?
    source == "hackernews"
  end

  def lobsters?
    source == "lobsters"
  end

  def devto?
    source == "devto"
  end

  def indiehackers?
    source == "indiehackers"
  end

  def read?
    read_at.present?
  end

  def mark_as_read!
    update!(read_at: Time.current) unless read?
  end

  def toggle_bookmark!
    if bookmarked?
      update!(bookmarked: false, bookmarked_at: nil)
    else
      update!(bookmarked: true, bookmarked_at: Time.current)
    end
  end

  def hot_score
    return 0 unless published_at

    hours_age = (Time.current - published_at) / 1.hour
    gravity = 1.5
    ((score + comments_count * 2) / ((hours_age + 2)**gravity)).round(2)
  end

  def engagement_ratio
    return 0 if score.zero?

    (comments_count.to_f / score * 100).round(1)
  end

  def discussion_url
    case source
    when "reddit"
      "https://reddit.com/r/#{source_name}/comments/#{external_id}"
    when "hackernews"
      "https://news.ycombinator.com/item?id=#{external_id}"
    when "lobsters"
      "https://lobste.rs/s/#{external_id}"
    when "devto"
      url
    when "indiehackers"
      url
    end
  end

  def domain
    URI.parse(url).host&.gsub(/^www\./, "")
  rescue URI::InvalidURIError
    nil
  end
end
