module Admin
  class ArticlesController < BaseController
    before_action :set_article, only: [:show, :destroy, :toggle_bookmark, :mark_read, :add_to_newsletter]

    def index
      @articles = apply_filters(Article.all)
      @articles = apply_sorting(@articles)
      @articles = @articles.limit(100)

      @stats = {
        total: Article.count,
        reddit: Article.from_reddit.count,
        hackernews: Article.from_hackernews.count,
        lobsters: Article.from_lobsters.count,
        devto: Article.from_devto.count,
        indiehackers: Article.from_indiehackers.count,
        today: Article.today.count,
        unread: Article.unread.count,
        bookmarked: Article.bookmarked.count,
        last_scrape: Article.maximum(:scraped_at)
      }
    end

    def show
      @article.mark_as_read!
    end

    def destroy
      @article.destroy
      redirect_to admin_articles_path, notice: "Article deleted."
    end

    def refresh
      ScrapeAllSourcesJob.perform_later
      redirect_to admin_articles_path, notice: "Scraping jobs enqueued. Refresh in a moment to see new articles."
    end

    def toggle_bookmark
      @article.toggle_bookmark!
      respond_to do |format|
        format.html { redirect_back_or_to(admin_articles_path) }
        format.turbo_stream
      end
    end

    def mark_read
      @article.mark_as_read!
      respond_to do |format|
        format.html { redirect_back_or_to(admin_articles_path) }
        format.turbo_stream
      end
    end

    def bookmarks
      @articles = Article.bookmarked.order(bookmarked_at: :desc)
    end

    def add_to_newsletter
      @newsletter = Newsletter.kept.draft.find(params[:newsletter_id])
      newsletter_article = @newsletter.newsletter_articles.build(article: @article)

      if newsletter_article.save
        respond_to do |format|
          format.html { redirect_back_or_to admin_article_path(@article), notice: "Article added to #{@newsletter.title}." }
          format.turbo_stream { flash.now[:notice] = "Article added to #{@newsletter.title}." }
        end
      else
        redirect_back_or_to admin_article_path(@article), alert: newsletter_article.errors.full_messages.join(", ")
      end
    end

    private

    def set_article
      @article = Article.find(params[:id])
    end

    def apply_filters(scope)
      scope = scope.where(source: params[:source]) if params[:source].present?
      scope = scope.where("title LIKE ?", "%#{params[:q]}%") if params[:q].present?
      scope = scope.min_score(params[:min_score].to_i) if params[:min_score].present?

      case params[:time]
      when "today" then scope = scope.today
      when "3days" then scope = scope.last_3_days
      when "week" then scope = scope.this_week
      end

      case params[:status]
      when "unread" then scope = scope.unread
      when "read" then scope = scope.read
      when "bookmarked" then scope = scope.bookmarked
      end

      scope
    end

    def apply_sorting(scope)
      case params[:sort]
      when "hot" then scope.by_hot_score
      when "score" then scope.popular
      when "comments" then scope.order(comments_count: :desc)
      else scope.recent
      end
    end
  end
end
