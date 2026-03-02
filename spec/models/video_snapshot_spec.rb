require "rails_helper"

RSpec.describe VideoSnapshot, type: :model do
  it "requires captured_at" do
    snapshot = build(:video_snapshot, captured_at: nil)
    expect(snapshot).not_to be_valid
  end
end
