module Admin
  class CreatorChannelsController < BaseController
    def index
      @creator_channels = CreatorChannel.order(:name)
    end

    def new
      @creator_channel = CreatorChannel.new(active: true)
    end

    def create
      @creator_channel = CreatorChannel.new(channel_params)
      if @creator_channel.save
        redirect_to admin_creator_channels_path, notice: "Channel added"
      else
        render :new, status: :unprocessable_content
      end
    end

    def edit
      @creator_channel = CreatorChannel.find(params[:id])
    end

    def update
      @creator_channel = CreatorChannel.find(params[:id])
      if @creator_channel.update(channel_params)
        redirect_to admin_creator_channels_path, notice: "Channel updated"
      else
        render :edit, status: :unprocessable_content
      end
    end

    private

    def channel_params
      attrs = params.require(:creator_channel).permit(:name, :handle, :youtube_channel_id, :active, :niche_tags)
      attrs[:niche_tags] = attrs[:niche_tags].to_s.split(",").map(&:strip).compact_blank
      attrs
    end
  end
end
