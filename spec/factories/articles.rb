FactoryBot.define do
  factory :article do
    sequence(:title) { |n| "Article Title #{n}" }
    sequence(:url) { |n| "https://example.com/article-#{n}" }
    sequence(:external_id) { |n| "ext_#{n}" }
    source { "reddit" }
    source_name { "technology" }
    author { "test_user" }
    score { 100 }
    comments_count { 25 }
    published_at { 2.hours.ago }
    scraped_at { Time.current }

    trait :from_reddit do
      source { "reddit" }
      source_name { "programming" }
    end

    trait :from_hackernews do
      source { "hackernews" }
      source_name { "Hacker News" }
    end

    trait :from_lobsters do
      source { "lobsters" }
      source_name { "Lobste.rs" }
    end

    trait :from_devto do
      source { "devto" }
      source_name { "Dev.to" }
    end

    trait :from_indiehackers do
      source { "indiehackers" }
      source_name { "Indie Hackers" }
    end

    trait :high_score do
      score { 1000 }
      comments_count { 250 }
    end

    trait :low_score do
      score { 10 }
      comments_count { 2 }
    end

    trait :old do
      published_at { 7.days.ago }
    end

    trait :recent do
      published_at { 1.hour.ago }
    end

    trait :bookmarked do
      bookmarked { true }
      bookmarked_at { 1.hour.ago }
    end

    trait :read do
      read_at { 30.minutes.ago }
    end
  end
end
