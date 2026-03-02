require "rails_helper"

RSpec.describe "Admin::CreatorChannels", type: :request do
  let(:auth) { ActionController::HttpAuthentication::Basic.encode_credentials("admin", "password") }

  it "creates a channel" do
    expect {
      post admin_creator_channels_path,
        params: {creator_channel: {name: "NetworkChuck", handle: "@networkchuck", youtube_channel_id: "abc", niche_tags: "linux, homelab", active: "1"}},
        headers: {"HTTP_AUTHORIZATION" => auth}
    }.to change(CreatorChannel, :count).by(1)
  end
end
