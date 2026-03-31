module Webhooks
  class ResendController < ApplicationController
    skip_before_action :verify_authenticity_token
    before_action :verify_webhook_signature!

    def create
      payload = JSON.parse(request.body.read)

      case payload["type"]
      when "email.bounced"
        handle_bounce(payload["data"])
      end

      head :ok
    end

    private

    def verify_webhook_signature!
      Resend::Webhooks.verify(
        payload: request.body.read,
        headers: {
          svix_id: request.headers["svix-id"],
          svix_timestamp: request.headers["svix-timestamp"],
          svix_signature: request.headers["svix-signature"]
        },
        webhook_secret: Rails.application.credentials.resend_webhook_secret
      )
    rescue
      head :unauthorized
    end

    def handle_bounce(data)
      subscriber = Subscriber.find_by(email: data["to"]&.first)
      subscriber&.unsubscribe!
    end
  end
end
