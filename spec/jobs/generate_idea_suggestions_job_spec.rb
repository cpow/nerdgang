require "rails_helper"

RSpec.describe GenerateIdeaSuggestionsJob, type: :job do
  it "delegates to Idea generation" do
    allow(Idea).to receive(:generate_from_trends!).and_return(5)

    result = described_class.perform_now(limit: 5)

    expect(Idea).to have_received(:generate_from_trends!).with(limit: 5)
    expect(result).to eq(5)
  end
end
