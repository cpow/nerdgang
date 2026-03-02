FactoryBot.define do
  factory :creator_video do
    association :creator_channel
    sequence(:youtube_video_id) { |n| "video-#{n}" }
    title { "Build log: unhinged project" }
    description { "A video" }
    published_at { 1.day.ago }
    duration_seconds { 600 }
    view_count { 1_000 }
    like_count { 100 }
    comment_count { 10 }
    tags { %w[raspberrypi coding] }
  end
end
