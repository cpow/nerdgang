require "rails_helper"

RSpec.describe "Subscribers", type: :request do
  describe "POST /subscribers" do
    context "with turbo_stream format" do
      it "creates a new subscriber" do
        expect {
          post subscribers_path, params: {subscriber: {email: "new@example.com"}}, as: :turbo_stream
        }.to change(Subscriber, :count).by(1)
      end

      it "replaces the form with success message" do
        post subscribers_path, params: {subscriber: {email: "new@example.com"}}, as: :turbo_stream
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("nl-subscribed-message")
        expect(response.body).to include("turbo-stream")
      end

      it "does not create a duplicate subscriber" do
        create(:subscriber, email: "existing@example.com")

        expect {
          post subscribers_path, params: {subscriber: {email: "existing@example.com"}}, as: :turbo_stream
        }.not_to change(Subscriber, :count)
      end

      it "replaces the form with already subscribed message for duplicates" do
        create(:subscriber, email: "existing@example.com")

        post subscribers_path, params: {subscriber: {email: "existing@example.com"}}, as: :turbo_stream
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("already subscribed")
      end

      it "handles case-insensitive duplicate detection" do
        create(:subscriber, email: "existing@example.com")

        expect {
          post subscribers_path, params: {subscriber: {email: "EXISTING@example.com"}}, as: :turbo_stream
        }.not_to change(Subscriber, :count)
      end

      it "returns error for invalid email" do
        post subscribers_path, params: {subscriber: {email: ""}}, as: :turbo_stream
        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include("turbo-stream")
      end
    end

    context "with html format" do
      it "creates a new subscriber and redirects" do
        expect {
          post subscribers_path, params: {subscriber: {email: "new@example.com"}}
        }.to change(Subscriber, :count).by(1)
        expect(response).to redirect_to(newsletters_path)
      end

      it "redirects with notice for duplicates" do
        create(:subscriber, email: "existing@example.com")

        post subscribers_path, params: {subscriber: {email: "existing@example.com"}},
          headers: {"HTTP_REFERER" => newsletters_url}
        expect(response).to redirect_to(newsletters_url)
        expect(flash[:notice]).to eq("You're already subscribed!")
      end

      it "redirects with alert for invalid email" do
        post subscribers_path, params: {subscriber: {email: ""}},
          headers: {"HTTP_REFERER" => newsletters_url}
        expect(response).to redirect_to(newsletters_url)
        expect(flash[:alert]).to be_present
      end
    end
  end
end
