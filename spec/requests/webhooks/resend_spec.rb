require "rails_helper"

RSpec.describe "Webhooks::Resend", type: :request do
  before do
    allow(Resend::Webhooks).to receive(:verify).and_return(true)
  end

  describe "POST /webhooks/resend" do
    context "with email.bounced event" do
      let!(:subscriber) { create(:subscriber) }

      let(:payload) do
        {
          type: "email.bounced",
          data: {to: [subscriber.email]}
        }.to_json
      end

      it "unsubscribes the bounced subscriber" do
        post "/webhooks/resend", params: payload, headers: webhook_headers

        expect(subscriber.reload).to be_unsubscribed
      end

      it "returns ok" do
        post "/webhooks/resend", params: payload, headers: webhook_headers

        expect(response).to have_http_status(:ok)
      end
    end

    context "with unknown subscriber email" do
      let(:payload) do
        {
          type: "email.bounced",
          data: {to: ["unknown@example.com"]}
        }.to_json
      end

      it "returns ok without error" do
        post "/webhooks/resend", params: payload, headers: webhook_headers

        expect(response).to have_http_status(:ok)
      end
    end

    context "with unhandled event type" do
      let(:payload) do
        {type: "email.delivered", data: {}}.to_json
      end

      it "returns ok" do
        post "/webhooks/resend", params: payload, headers: webhook_headers

        expect(response).to have_http_status(:ok)
      end
    end

    context "with invalid signature" do
      before do
        allow(Resend::Webhooks).to receive(:verify).and_raise(StandardError)
      end

      it "returns unauthorized" do
        post "/webhooks/resend", params: {}.to_json, headers: webhook_headers

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  private

  def webhook_headers
    {
      "Content-Type" => "application/json",
      "svix-id" => "msg_test123",
      "svix-timestamp" => Time.now.to_i.to_s,
      "svix-signature" => "v1,test_signature"
    }
  end
end
