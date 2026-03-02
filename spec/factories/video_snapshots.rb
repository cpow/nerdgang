FactoryBot.define do
  factory :video_snapshot do
    association :creator_video
    captured_at { Time.current }
    view_count { 1_000 }
    like_count { 100 }
    comment_count { 10 }
  end
end
