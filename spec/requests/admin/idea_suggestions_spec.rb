require "rails_helper"

RSpec.describe "Admin idea suggestions", type: :request do
  let(:auth) { ActionController::HttpAuthentication::Basic.encode_credentials("admin", "password") }

  it "triggers suggestion generation" do
    allow(GenerateIdeaSuggestionsJob).to receive(:perform_now).and_return(3)

    post generate_suggestions_admin_creator_dashboard_index_path,
      headers: {"HTTP_AUTHORIZATION" => auth}

    expect(GenerateIdeaSuggestionsJob).to have_received(:perform_now).with(limit: 10)
    expect(response).to redirect_to(admin_creator_dashboard_index_path)
  end
end
