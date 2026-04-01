require "rails_helper"

RSpec.describe "Admin::Subscribers", type: :request do
  let(:valid_credentials) do
    ActionController::HttpAuthentication::Basic.encode_credentials("admin", "password")
  end

  let(:headers) { {"HTTP_AUTHORIZATION" => valid_credentials} }

  describe "GET /admin/subscribers" do
    it "requires authentication" do
      get admin_subscribers_path
      expect(response).to have_http_status(:unauthorized)
    end

    it "returns success with valid credentials" do
      get admin_subscribers_path, headers: headers
      expect(response).to have_http_status(:success)
    end

    it "displays subscribers" do
      subscriber = create(:subscriber, email: "reader@example.com")

      get admin_subscribers_path, headers: headers

      expect(response.body).to include("reader@example.com")
    end

    it "shows active status for subscribed users" do
      create(:subscriber)

      get admin_subscribers_path, headers: headers

      expect(response.body).to include("Active")
    end

    it "shows unsubscribed status" do
      create(:subscriber, :unsubscribed)

      get admin_subscribers_path, headers: headers

      expect(response.body).to include("Unsubscribed")
    end

    it "links to subscriber show page" do
      subscriber = create(:subscriber)

      get admin_subscribers_path, headers: headers

      expect(response.body).to include(admin_subscriber_path(subscriber))
    end
  end

  describe "GET /admin/subscribers/:id" do
    it "requires authentication" do
      subscriber = create(:subscriber)
      get admin_subscriber_path(subscriber)
      expect(response).to have_http_status(:unauthorized)
    end

    it "returns success with valid credentials" do
      subscriber = create(:subscriber)

      get admin_subscriber_path(subscriber), headers: headers

      expect(response).to have_http_status(:success)
    end

    it "displays subscriber email" do
      subscriber = create(:subscriber, email: "reader@example.com")

      get admin_subscriber_path(subscriber), headers: headers

      expect(response.body).to include("reader@example.com")
    end

    it "shows active status for subscribed user" do
      subscriber = create(:subscriber)

      get admin_subscriber_path(subscriber), headers: headers

      expect(response.body).to include("Active")
    end

    it "shows unsubscribed status and date" do
      subscriber = create(:subscriber, :unsubscribed)

      get admin_subscriber_path(subscriber), headers: headers

      expect(response.body).to include("Unsubscribed")
      expect(response.body).to include("Unsubscribed On")
    end

    it "shows user_unsubscribed reason" do
      subscriber = create(:subscriber, unsubscribed_at: 1.day.ago, unsubscribe_reason: "user_unsubscribed")

      get admin_subscriber_path(subscriber), headers: headers

      expect(response.body).to include("User Unsubscribed")
      expect(response.body).to include("opted out via the unsubscribe link")
    end

    it "shows spam_complaint reason" do
      subscriber = create(:subscriber, unsubscribed_at: 1.day.ago, unsubscribe_reason: "spam_complaint")

      get admin_subscriber_path(subscriber), headers: headers

      expect(response.body).to include("Spam Complaint")
      expect(response.body).to include("marked the email as spam")
    end

    it "shows email_bounced reason" do
      subscriber = create(:subscriber, unsubscribed_at: 1.day.ago, unsubscribe_reason: "email_bounced")

      get admin_subscriber_path(subscriber), headers: headers

      expect(response.body).to include("Email Bounced")
      expect(response.body).to include("Resend webhook")
    end

    it "shows unknown reason when no reason is set" do
      subscriber = create(:subscriber, unsubscribed_at: 1.day.ago, unsubscribe_reason: nil)

      get admin_subscriber_path(subscriber), headers: headers

      expect(response.body).to include("Unknown")
    end

    it "shows delete button" do
      subscriber = create(:subscriber)

      get admin_subscriber_path(subscriber), headers: headers

      expect(response.body).to include("Delete Subscriber")
    end
  end

  describe "DELETE /admin/subscribers/:id" do
    it "requires authentication" do
      subscriber = create(:subscriber)
      delete admin_subscriber_path(subscriber)
      expect(response).to have_http_status(:unauthorized)
    end

    it "soft deletes the subscriber" do
      subscriber = create(:subscriber)

      delete admin_subscriber_path(subscriber), headers: headers

      expect(subscriber.reload.discarded_at).to be_present
    end

    it "redirects to subscribers index" do
      subscriber = create(:subscriber)

      delete admin_subscriber_path(subscriber), headers: headers

      expect(response).to redirect_to(admin_subscribers_path)
    end

    it "sets a success notice" do
      subscriber = create(:subscriber)

      delete admin_subscriber_path(subscriber), headers: headers

      expect(flash[:notice]).to eq("Subscriber was successfully deleted.")
    end
  end
end
