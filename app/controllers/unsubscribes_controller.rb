class UnsubscribesController < ApplicationController
  layout "newsletter"

  def show
    @subscriber = Subscriber.find_by(unsubscribe_token: params[:token])

    if @subscriber.nil?
      render :not_found, status: :not_found
    elsif @subscriber.unsubscribed?
      render :already_unsubscribed
    else
      @subscriber.unsubscribe!(reason: "user_unsubscribed")
      render :success
    end
  end
end
