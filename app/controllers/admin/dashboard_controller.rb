module Admin
  class DashboardController < BaseController
    def index
      @stats = {
        total_articles: Article.count,
        articles_today: Article.today.count,
        articles_this_week: Article.this_week.count,
        by_source: Article.group(:source).count,
        last_reddit_scrape: Article.from_reddit.maximum(:scraped_at),
        last_hn_scrape: Article.from_hackernews.maximum(:scraped_at),
        total_subscribers: Subscriber.count,
        subscribers_today: Subscriber.where("created_at >= ?", 24.hours.ago).count,
        subscribers_this_week: Subscriber.where("created_at >= ?", 7.days.ago).count
      }

      @subscriber_daily_signups = subscriber_daily_signups

      @recent_articles = Article.recent.limit(10)
      @top_articles = Article.this_week.popular.limit(10)
    end

    private

    def subscriber_daily_signups
      start_date = 29.days.ago.to_date
      end_date = Date.current

      counts = Subscriber.where(created_at: start_date.beginning_of_day..end_date.end_of_day)
        .group("date(created_at)")
        .count

      (start_date..end_date).map do |date|
        {date: date, count: counts[date.to_s] || 0}
      end
    end
  end
end
