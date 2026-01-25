FactoryBot.define do
  factory :newsletter_article do
    newsletter
    article
    position { nil } # Will be auto-set by model

    trait :with_commentary do
      commentary { "This is why I found this article interesting." }
    end
  end
end
