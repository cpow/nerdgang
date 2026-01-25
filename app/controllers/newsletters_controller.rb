class NewslettersController < ApplicationController
  layout "newsletter"

  def index
    @newsletters = Newsletter.kept.published.recently_published
  end

  def show
    @newsletter = Newsletter.kept.published.find_by!(slug: params[:slug])
  end
end
