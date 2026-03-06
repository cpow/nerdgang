module Admin
  class CreatorDashboardController < BaseController
    def index
      @creator_channels = CreatorChannel.active.order(:name)
      @videos = filtered_videos.limit(50)
      @ideas = Idea.includes(:creator_channel, :creator_video).order(score: :desc, created_at: :desc).limit(30)

      # Recent videos by channel, sorted by velocity (views per hour)
      @recent_videos_by_channel = @creator_channels.each_with_object({}) do |channel, hash|
        hash[channel] = channel.creator_videos
          .where("published_at >= ?", 14.days.ago)
          .select("creator_videos.*, (view_count * 1.0 / NULLIF((julianday('now') - julianday(published_at)) * 24, 0)) AS views_per_hour")
          .order(Arel.sql("views_per_hour DESC NULLS LAST"))
          .limit(5)
      end
    end

    def sync
      SyncYoutubeDataJob.perform_now
      redirect_to admin_creator_dashboard_index_path, notice: "YouTube sync finished"
    end

    def generate_suggestions
      created = GenerateIdeaSuggestionsJob.perform_now(limit: 10)
      redirect_to admin_creator_dashboard_index_path, notice: "Generated #{created} idea suggestions"
    end

    private

    def filtered_videos
      scope = CreatorVideo.includes(:creator_channel).order(published_at: :desc)
      return scope if params[:days].blank?

      scope.where("published_at >= ?", params[:days].to_i.days.ago)
    end
  end
end
