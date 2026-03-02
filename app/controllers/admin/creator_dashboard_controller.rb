module Admin
  class CreatorDashboardController < BaseController
    def index
      @creator_channels = CreatorChannel.active.order(:name)
      @videos = filtered_videos.limit(50)
      @ideas = Idea.includes(:creator_channel, :creator_video).order(score: :desc, created_at: :desc).limit(30)
      @top_competitor_videos = CreatorVideo.joins(:creator_channel)
        .where.not(creator_channels: {handle: "@typecraft_dev"})
        .order(view_count: :desc)
        .limit(20)
    end

    def sync
      SyncYoutubeDataJob.perform_now
      redirect_to admin_creator_dashboard_index_path, notice: "YouTube sync finished"
    end

    private

    def filtered_videos
      scope = CreatorVideo.includes(:creator_channel).order(published_at: :desc)
      return scope if params[:days].blank?

      scope.where("published_at >= ?", params[:days].to_i.days.ago)
    end
  end
end
