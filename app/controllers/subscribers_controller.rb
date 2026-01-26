class SubscribersController < ApplicationController
  def create
    email = subscriber_params[:email].downcase.strip
    existing = Subscriber.find_by(email: email)

    if existing
      respond_subscribed("You're already subscribed!")
    else
      subscriber = Subscriber.new(email: email)
      if subscriber.save
        respond_subscribed("You're subscribed! Thanks, nerd.")
      else
        respond_to do |format|
          format.turbo_stream do
            render turbo_stream: turbo_stream.update(
              "subscribe-form-error",
              html: helpers.content_tag(:p, subscriber.errors.full_messages.join(", "), class: "nl-form-error")
            ), status: :unprocessable_content
          end
          format.html { redirect_back_or_to(newsletters_path, alert: subscriber.errors.full_messages.join(", ")) }
        end
      end
    end
  end

  private

  def subscriber_params
    params.expect(subscriber: [:email])
  end

  def respond_subscribed(message)
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "subscribe-form",
          partial: "subscribers/subscribed",
          locals: {message: message}
        )
      end
      format.html { redirect_back_or_to(newsletters_path, notice: message) }
    end
  end
end
