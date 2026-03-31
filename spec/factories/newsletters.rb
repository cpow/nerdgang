FactoryBot.define do
  factory :newsletter do
    sequence(:title) { |n| "Weekly Newsletter ##{n}" }
    sequence(:slug) { |n| "weekly-newsletter-#{n}" }

    trait :published do
      published_at { 1.day.ago }
    end

    trait :draft do
      published_at { nil }
    end

    trait :with_blurb do
      after(:build) do |newsletter|
        newsletter.blurb = ActionText::Content.new("This is the newsletter blurb with some content.")
      end
    end

    trait :discarded do
      discarded_at { 1.hour.ago }
    end

    trait :with_pdf do
      after(:build) do |newsletter|
        newsletter.pdf_attachment.attach(
          io: StringIO.new("fake pdf content"),
          filename: "newsletter.pdf",
          content_type: "application/pdf"
        )
      end
    end

    trait :sent do
      published_at { 2.days.ago }
      sent_at { 1.day.ago }
    end
  end
end
