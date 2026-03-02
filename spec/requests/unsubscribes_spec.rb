require "rails_helper"

RSpec.describe "Unsubscribes", type: :request do
  describe "GET /unsubscribe/:token" do
    context "with valid token" do
      let(:subscriber) { create(:subscriber) }

      it "unsubscribes the user" do
        get unsubscribe_path(token: subscriber.unsubscribe_token)

        expect(subscriber.reload.unsubscribed_at).to be_present
      end

      it "renders the success page" do
        get unsubscribe_path(token: subscriber.unsubscribe_token)

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("You've been unsubscribed")
      end
    end

    context "with already unsubscribed user" do
      let(:subscriber) { create(:subscriber, :unsubscribed) }

      it "does not change unsubscribed_at" do
        original_time = subscriber.unsubscribed_at

        get unsubscribe_path(token: subscriber.unsubscribe_token)

        expect(subscriber.reload.unsubscribed_at).to eq(original_time)
      end

      it "renders the already unsubscribed page" do
        get unsubscribe_path(token: subscriber.unsubscribe_token)

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("already unsubscribed")
      end
    end

    context "with invalid token" do
      it "renders the not found page" do
        get unsubscribe_path(token: "invalid-token")

        expect(response).to have_http_status(:not_found)
        expect(response.body).to include("Link not found")
      end
    end
  end
end
