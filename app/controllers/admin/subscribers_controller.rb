module Admin
  class SubscribersController < BaseController
    def index
      @subscribers = Subscriber.order(created_at: :desc)
    end

    def show
      @subscriber = Subscriber.find(params[:id])
    end
  end
end
