require "rails_helper"

RSpec.describe Idea, type: :model do
  it "accepts valid status" do
    idea = build(:idea, status: "backlog")
    expect(idea).to be_valid
  end

  it "rejects invalid status" do
    idea = build(:idea, status: "invalid")
    expect(idea).not_to be_valid
  end
end
