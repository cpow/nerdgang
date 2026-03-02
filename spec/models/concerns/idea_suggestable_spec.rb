require "rails_helper"

RSpec.describe IdeaSuggestable do
  it "generates ideas from trending videos" do
    channel = create(:creator_channel)
    create(:creator_video, creator_channel: channel, title: "Build insane Raspberry Pi project", tags: %w[raspberrypi build], view_count: 50_000)

    expect {
      Idea.generate_from_trends!(limit: 3)
    }.to change(Idea, :count).by_at_least(1)
  end
end
