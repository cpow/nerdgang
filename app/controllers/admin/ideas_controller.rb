module Admin
  class IdeasController < BaseController
    def index
      @ideas = Idea.includes(:creator_channel, :creator_video).order(score: :desc, created_at: :desc)
    end

    def new
      @idea = Idea.new(status: "backlog")
    end

    def create
      @idea = Idea.new(idea_params)
      if @idea.save
        redirect_to admin_ideas_path, notice: "Idea created"
      else
        render :new, status: :unprocessable_content
      end
    end

    def edit
      @idea = Idea.find(params[:id])
    end

    def update
      @idea = Idea.find(params[:id])
      if @idea.update(idea_params)
        redirect_to admin_ideas_path, notice: "Idea updated"
      else
        render :edit, status: :unprocessable_content
      end
    end

    private

    def idea_params
      params.require(:idea).permit(
        :title, :angle, :hook, :thumbnail_concept, :key_points,
        :hardware_components, :difficulty, :status, :score, :notes,
        :creator_channel_id, :creator_video_id
      )
    end
  end
end
