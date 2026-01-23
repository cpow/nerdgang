module Admin
  class DashboardController < BaseController
    def index
      @stats = {
        total_articles: Article.count,
        articles_today: Article.today.count,
        articles_this_week: Article.this_week.count,
        by_source: Article.group(:source).count,
        last_reddit_scrape: Article.from_reddit.maximum(:scraped_at),
        last_hn_scrape: Article.from_hackernews.maximum(:scraped_at)
      }

      @recent_articles = Article.recent.limit(10)
      @top_articles = Article.this_week.popular.limit(10)
    end
  end
end
