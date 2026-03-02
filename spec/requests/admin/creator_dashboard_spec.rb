require "rails_helper"

RSpec.describe "Admin::CreatorDashboard", type: :request do
  let(:auth) { ActionController::HttpAuthentication::Basic.encode_credentials("admin", "password") }

  it "renders index" do
    get admin_creator_dashboard_index_path, headers: {"HTTP_AUTHORIZATION" => auth}
    expect(response).to have_http_status(:ok)
  end

  it "runs sync" do
    expect(SyncYoutubeDataJob).to receive(:perform_now)
    post sync_admin_creator_dashboard_index_path, headers: {"HTTP_AUTHORIZATION" => auth}
    expect(response).to redirect_to(admin_creator_dashboard_index_path)
  end
end
