module Admin
  class NewsletterArticlesController < BaseController
    before_action :set_newsletter_article, only: [:destroy, :move_up, :move_down]

    def create
      @newsletter_article = NewsletterArticle.new(newsletter_article_params)

      if @newsletter_article.save
        respond_to do |format|
          format.html { redirect_to admin_newsletter_path(@newsletter_article.newsletter), notice: "Article added to newsletter." }
          format.turbo_stream
        end
      else
        redirect_to admin_newsletter_path(@newsletter_article.newsletter), alert: @newsletter_article.errors.full_messages.join(", ")
      end
    end

    def destroy
      newsletter = @newsletter_article.newsletter
      @newsletter_article.destroy

      respond_to do |format|
        format.html { redirect_to admin_newsletter_path(newsletter), notice: "Article removed from newsletter." }
        format.turbo_stream
      end
    end

    def move_up
      @newsletter_article.move_up
      redirect_to admin_newsletter_path(@newsletter_article.newsletter)
    end

    def move_down
      @newsletter_article.move_down
      redirect_to admin_newsletter_path(@newsletter_article.newsletter)
    end

    private

    def set_newsletter_article
      @newsletter_article = NewsletterArticle.find(params[:id])
    end

    def newsletter_article_params
      params.require(:newsletter_article).permit(:newsletter_id, :article_id, :commentary)
    end
  end
end
