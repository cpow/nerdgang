require "rails_helper"

RSpec.describe SyncYoutubeDataJob, type: :job do
  it "calls creator channel sync" do
    allow(CreatorChannel).to receive(:sync_from_youtube!)
    described_class.perform_now
    expect(CreatorChannel).to have_received(:sync_from_youtube!)
  end
end
