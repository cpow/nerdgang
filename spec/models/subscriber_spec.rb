require "rails_helper"

RSpec.describe Subscriber, type: :model do
  describe "validations" do
    subject { build(:subscriber) }

    it { is_expected.to be_valid }

    it "requires an email" do
      subject.email = nil
      expect(subject).not_to be_valid
      expect(subject.errors[:email]).to include("can't be blank")
    end

    it "requires a unique email" do
      create(:subscriber, email: "test@example.com")
      duplicate = build(:subscriber, email: "test@example.com")
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:email]).to include("has already been taken")
    end

    it "requires a unique email case-insensitively" do
      create(:subscriber, email: "test@example.com")
      duplicate = build(:subscriber, email: "TEST@example.com")
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:email]).to include("has already been taken")
    end

    it "requires a valid email format" do
      subject.email = "not-an-email"
      expect(subject).not_to be_valid
      expect(subject.errors[:email]).to include("is invalid")
    end

    it "accepts valid email addresses" do
      subject.email = "user@example.com"
      expect(subject).to be_valid
    end
  end

  describe "discard" do
    it "soft deletes with discard" do
      subscriber = create(:subscriber)
      subscriber.discard!
      expect(subscriber.discarded?).to be true
      expect(Subscriber.all).not_to include(subscriber)
      expect(Subscriber.with_discarded).to include(subscriber)
    end
  end
end
