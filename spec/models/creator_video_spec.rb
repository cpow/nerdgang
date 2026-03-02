require "rails_helper"

RSpec.describe CreatorVideo, type: :model do
  it "calculates traction score" do
    video = build(:creator_video, view_count: 1_000, like_count: 100, comment_count: 10)
    expect(video.traction_score).to eq(1_230)
  end

  it "captures a snapshot" do
    video = create(:creator_video)
    expect { video.capture_snapshot! }.to change(VideoSnapshot, :count).by(1)
  end
end
