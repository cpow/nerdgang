require "rails_helper"

RSpec.describe "Admin::Dashboard", type: :request do
  let(:valid_credentials) do
    ActionController::HttpAuthentication::Basic.encode_credentials("admin", "password")
  end

  let(:headers) { {"HTTP_AUTHORIZATION" => valid_credentials} }

  describe "GET /admin" do
    it "requires authentication" do
      get admin_root_path
      expect(response).to have_http_status(:unauthorized)
    end

    it "returns success with valid credentials" do
      get admin_root_path, headers: headers
      expect(response).to have_http_status(:success)
    end

    it "displays stats" do
      create_list(:article, 3, :from_reddit)
      create_list(:article, 2, :from_hackernews)

      get admin_root_path, headers: headers

      expect(response.body).to include("Total Articles")
      expect(response.body).to include("5") # total count
    end

    it "displays recent articles" do
      create(:article, title: "Recent Test Article", published_at: 1.hour.ago)

      get admin_root_path, headers: headers

      expect(response.body).to include("Recent Test Article")
    end

    it "displays top articles this week" do
      create(:article, title: "Popular Article", score: 1000, published_at: 2.days.ago)

      get admin_root_path, headers: headers

      expect(response.body).to include("Popular Article")
    end
  end
end
