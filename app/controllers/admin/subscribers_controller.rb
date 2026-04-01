module Admin
  class SubscribersController < BaseController
    before_action :set_subscriber, only: [:show, :destroy]

    def index
      @subscribers = Subscriber.order(created_at: :desc)
    end

    def show
    end

    def destroy
      @subscriber.discard
      redirect_to admin_subscribers_path, notice: "Subscriber was successfully deleted."
    end

    private

    def set_subscriber
      @subscriber = Subscriber.find(params[:id])
    end
  end
end
