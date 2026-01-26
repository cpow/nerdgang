module Admin
  class SubscribersController < BaseController
    def index
      @subscribers = Subscriber.order(created_at: :desc)
    end
  end
end
