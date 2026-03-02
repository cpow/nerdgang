FactoryBot.define do
  factory :creator_channel do
    sequence(:name) { |n| "Creator #{n}" }
    sequence(:handle) { |n| "@creator#{n}" }
    sequence(:youtube_channel_id) { |n| "channel-#{n}" }
    niche_tags { %w[builder raspberrypi] }
    active { true }
  end
end
