module Admin
  class NewslettersController < BaseController
    before_action :set_newsletter, only: [:show, :edit, :update, :destroy, :publish, :unpublish, :send_newsletter, :preview]

    def index
      @newsletters = Newsletter.kept.by_recent
    end

    def show
    end

    def new
      @newsletter = Newsletter.new
    end

    def create
      @newsletter = Newsletter.new(newsletter_params)

      if @newsletter.save
        redirect_to admin_newsletter_path(@newsletter), notice: "Newsletter was successfully created."
      else
        render :new, status: :unprocessable_content
      end
    end

    def edit
    end

    def update
      if @newsletter.update(newsletter_params)
        redirect_to admin_newsletter_path(@newsletter), notice: "Newsletter was successfully updated."
      else
        render :edit, status: :unprocessable_content
      end
    end

    def destroy
      @newsletter.discard
      redirect_to admin_newsletters_path, notice: "Newsletter was successfully deleted."
    end

    def publish
      @newsletter.publish!
      redirect_to admin_newsletter_path(@newsletter), notice: "Newsletter was published."
    end

    def unpublish
      @newsletter.unpublish!
      redirect_to admin_newsletter_path(@newsletter), notice: "Newsletter was unpublished."
    end

    def send_newsletter
      if @newsletter.sent?
        redirect_to admin_newsletter_path(@newsletter), alert: "Newsletter has already been sent."
      elsif !@newsletter.published?
        redirect_to admin_newsletter_path(@newsletter), alert: "Newsletter must be published before sending."
      else
        subscriber_count = Subscriber.subscribed.count
        SendNewsletterJob.perform_later(@newsletter.id)
        redirect_to admin_newsletter_path(@newsletter), notice: "Newsletter is being sent to #{subscriber_count} subscribers."
      end
    end

    def preview
      @subscriber = Subscriber.new(email: "preview@example.com", unsubscribe_token: "preview-token")
      mail = NewsletterMailer.weekly_digest(@subscriber, @newsletter)
      render html: mail.html_part.body.to_s.html_safe, layout: false
    end

    private

    def set_newsletter
      @newsletter = Newsletter.kept.find_by(slug: params[:id]) || Newsletter.kept.find(params[:id])
    end

    def newsletter_params
      params.require(:newsletter).permit(:title, :slug, :blurb, :cover_image, :pdf_attachment)
    end
  end
end
