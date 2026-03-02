require "rails_helper"

RSpec.describe CreatorChannel, type: :model do
  it "validates handle uniqueness" do
    create(:creator_channel, handle: "@abc")
    dup = build(:creator_channel, handle: "@abc")
    expect(dup).not_to be_valid
  end

  it "returns niche tags array" do
    channel = build(:creator_channel, niche_tags: ["rails", "pi"])
    expect(channel.niche_tags_array).to eq(["rails", "pi"])
  end
end
