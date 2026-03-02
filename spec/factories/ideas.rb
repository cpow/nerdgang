FactoryBot.define do
  factory :idea do
    title { "Build an absurd Pi robot" }
    angle { "Funny, builder-first POV" }
    status { "backlog" }
    score { 42 }
    notes { "Track similar videos" }
    association :creator_channel
  end
end
