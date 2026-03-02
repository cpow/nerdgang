FactoryBot.define do
  factory :subscriber do
    sequence(:email) { |n| "subscriber#{n}@example.com" }

    trait :unsubscribed do
      unsubscribed_at { 1.day.ago }
    end
  end
end
