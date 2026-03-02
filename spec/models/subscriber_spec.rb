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

  describe "unsubscribe_token" do
    it "generates a token on create" do
      subscriber = create(:subscriber)
      expect(subscriber.unsubscribe_token).to be_present
    end

    it "generates a unique token" do
      subscriber1 = create(:subscriber)
      subscriber2 = create(:subscriber)
      expect(subscriber1.unsubscribe_token).not_to eq(subscriber2.unsubscribe_token)
    end

    it "does not overwrite existing token" do
      subscriber = build(:subscriber, unsubscribe_token: "existing-token")
      subscriber.save!
      expect(subscriber.unsubscribe_token).to eq("existing-token")
    end
  end

  describe "scopes" do
    describe ".subscribed" do
      it "returns only subscribed subscribers" do
        subscribed = create(:subscriber)
        unsubscribed = create(:subscriber, :unsubscribed)

        expect(Subscriber.subscribed).to include(subscribed)
        expect(Subscriber.subscribed).not_to include(unsubscribed)
      end
    end

    describe ".unsubscribed" do
      it "returns only unsubscribed subscribers" do
        subscribed = create(:subscriber)
        unsubscribed = create(:subscriber, :unsubscribed)

        expect(Subscriber.unsubscribed).not_to include(subscribed)
        expect(Subscriber.unsubscribed).to include(unsubscribed)
      end
    end
  end

  describe "#subscribed?" do
    it "returns true when unsubscribed_at is nil" do
      subscriber = build(:subscriber, unsubscribed_at: nil)
      expect(subscriber.subscribed?).to be true
    end

    it "returns false when unsubscribed_at is present" do
      subscriber = build(:subscriber, unsubscribed_at: Time.current)
      expect(subscriber.subscribed?).to be false
    end
  end

  describe "#unsubscribed?" do
    it "returns false when unsubscribed_at is nil" do
      subscriber = build(:subscriber, unsubscribed_at: nil)
      expect(subscriber.unsubscribed?).to be false
    end

    it "returns true when unsubscribed_at is present" do
      subscriber = build(:subscriber, unsubscribed_at: Time.current)
      expect(subscriber.unsubscribed?).to be true
    end
  end

  describe "#unsubscribe!" do
    it "sets unsubscribed_at to current time" do
      subscriber = create(:subscriber)
      freeze_time do
        subscriber.unsubscribe!
        expect(subscriber.unsubscribed_at).to eq(Time.current)
      end
    end
  end

  describe "#resubscribe!" do
    it "clears unsubscribed_at" do
      subscriber = create(:subscriber, :unsubscribed)
      subscriber.resubscribe!
      expect(subscriber.unsubscribed_at).to be_nil
    end
  end
end
