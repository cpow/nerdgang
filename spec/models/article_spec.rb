require "rails_helper"

RSpec.describe Article, type: :model do
  describe "validations" do
    subject { build(:article) }

    it { is_expected.to be_valid }

    it "requires a title" do
      subject.title = nil
      expect(subject).not_to be_valid
      expect(subject.errors[:title]).to include("can't be blank")
    end

    it "requires a url" do
      subject.url = nil
      expect(subject).not_to be_valid
      expect(subject.errors[:url]).to include("can't be blank")
    end

    it "requires an external_id" do
      subject.external_id = nil
      expect(subject).not_to be_valid
      expect(subject.errors[:external_id]).to include("can't be blank")
    end

    it "requires a source" do
      subject.source = nil
      expect(subject).not_to be_valid
      expect(subject.errors[:source]).to include("can't be blank")
    end

    it "requires source to be reddit or hackernews" do
      subject.source = "invalid"
      expect(subject).not_to be_valid
      expect(subject.errors[:source]).to include("is not included in the list")
    end

    it "requires scraped_at" do
      subject.scraped_at = nil
      expect(subject).not_to be_valid
      expect(subject.errors[:scraped_at]).to include("can't be blank")
    end

    it "requires unique external_id per source" do
      create(:article, source: "reddit", external_id: "abc123")
      duplicate = build(:article, source: "reddit", external_id: "abc123")
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:external_id]).to include("has already been taken")
    end

    it "allows same external_id for different sources" do
      create(:article, source: "reddit", external_id: "abc123")
      different_source = build(:article, source: "hackernews", external_id: "abc123")
      expect(different_source).to be_valid
    end
  end

  describe "scopes" do
    describe ".from_reddit" do
      it "returns only reddit articles" do
        reddit_article = create(:article, :from_reddit)
        create(:article, :from_hackernews)

        expect(Article.from_reddit).to eq([reddit_article])
      end
    end

    describe ".from_hackernews" do
      it "returns only hackernews articles" do
        create(:article, :from_reddit)
        hn_article = create(:article, :from_hackernews)

        expect(Article.from_hackernews).to eq([hn_article])
      end
    end

    describe ".recent" do
      it "orders by published_at desc" do
        old = create(:article, published_at: 2.days.ago)
        new = create(:article, published_at: 1.hour.ago)

        expect(Article.recent.to_a).to eq([new, old])
      end
    end

    describe ".popular" do
      it "orders by score desc" do
        low = create(:article, score: 10)
        high = create(:article, score: 1000)

        expect(Article.popular.to_a).to eq([high, low])
      end
    end

    describe ".today" do
      it "returns articles published in last 24 hours" do
        today = create(:article, published_at: 12.hours.ago)
        old = create(:article, published_at: 2.days.ago)

        expect(Article.today).to include(today)
        expect(Article.today).not_to include(old)
      end
    end

    describe ".this_week" do
      it "returns articles published in last 7 days" do
        this_week = create(:article, published_at: 3.days.ago)
        old = create(:article, published_at: 10.days.ago)

        expect(Article.this_week).to include(this_week)
        expect(Article.this_week).not_to include(old)
      end
    end

    describe ".bookmarked" do
      it "returns only bookmarked articles" do
        bookmarked = create(:article, :bookmarked)
        create(:article)

        expect(Article.bookmarked).to eq([bookmarked])
      end
    end

    describe ".unread" do
      it "returns only unread articles" do
        unread = create(:article)
        create(:article, :read)

        expect(Article.unread).to eq([unread])
      end
    end

    describe ".read" do
      it "returns only read articles" do
        create(:article)
        read = create(:article, :read)

        expect(Article.read).to eq([read])
      end
    end

    describe ".min_score" do
      it "returns articles with score >= threshold" do
        high = create(:article, score: 500)
        low = create(:article, score: 50)

        expect(Article.min_score(100)).to include(high)
        expect(Article.min_score(100)).not_to include(low)
      end
    end

    describe ".stale" do
      it "returns articles older than 14 days" do
        stale = create(:article, published_at: 15.days.ago)
        recent = create(:article, published_at: 7.days.ago)

        expect(Article.stale).to include(stale)
        expect(Article.stale).not_to include(recent)
      end
    end

    describe "default_scope (kept)" do
      it "excludes discarded articles by default" do
        kept = create(:article)
        discarded = create(:article)
        discarded.discard!

        expect(Article.all).to include(kept)
        expect(Article.all).not_to include(discarded)
      end

      it "includes discarded articles with with_discarded" do
        kept = create(:article)
        discarded = create(:article)
        discarded.discard!

        expect(Article.with_discarded).to include(kept, discarded)
      end
    end
  end

  describe ".discard_stale!" do
    it "discards all stale articles" do
      stale1 = create(:article, published_at: 15.days.ago)
      stale2 = create(:article, published_at: 20.days.ago)
      recent = create(:article, published_at: 7.days.ago)

      Article.discard_stale!

      expect(stale1.reload.discarded?).to be true
      expect(stale2.reload.discarded?).to be true
      expect(recent.reload.discarded?).to be false
    end
  end

  describe "instance methods" do
    describe "#reddit?" do
      it "returns true for reddit articles" do
        article = build(:article, source: "reddit")
        expect(article.reddit?).to be true
      end

      it "returns false for hackernews articles" do
        article = build(:article, source: "hackernews")
        expect(article.reddit?).to be false
      end
    end

    describe "#hackernews?" do
      it "returns true for hackernews articles" do
        article = build(:article, source: "hackernews")
        expect(article.hackernews?).to be true
      end

      it "returns false for reddit articles" do
        article = build(:article, source: "reddit")
        expect(article.hackernews?).to be false
      end
    end

    describe "#read?" do
      it "returns true when read_at is present" do
        article = build(:article, read_at: Time.current)
        expect(article.read?).to be true
      end

      it "returns false when read_at is nil" do
        article = build(:article, read_at: nil)
        expect(article.read?).to be false
      end
    end

    describe "#mark_as_read!" do
      it "sets read_at to current time" do
        article = create(:article, read_at: nil)
        freeze_time do
          article.mark_as_read!
          expect(article.read_at).to be_within(1.second).of(Time.current)
        end
      end

      it "does not update if already read" do
        original_time = 1.hour.ago
        article = create(:article, read_at: original_time)
        article.mark_as_read!
        expect(article.read_at).to be_within(1.second).of(original_time)
      end
    end

    describe "#toggle_bookmark!" do
      it "bookmarks an unbookmarked article" do
        article = create(:article, bookmarked: false)
        freeze_time do
          article.toggle_bookmark!
          expect(article.bookmarked?).to be true
          expect(article.bookmarked_at).to be_within(1.second).of(Time.current)
        end
      end

      it "unbookmarks a bookmarked article" do
        article = create(:article, :bookmarked)
        article.toggle_bookmark!
        expect(article.bookmarked?).to be false
        expect(article.bookmarked_at).to be_nil
      end
    end

    describe "#hot_score" do
      it "returns higher score for recent high-engagement articles" do
        recent_hot = create(:article, score: 500, comments_count: 100, published_at: 1.hour.ago)
        old_hot = create(:article, score: 500, comments_count: 100, published_at: 24.hours.ago)

        expect(recent_hot.hot_score).to be > old_hot.hot_score
      end

      it "returns 0 when published_at is nil" do
        article = build(:article, published_at: nil)
        expect(article.hot_score).to eq(0)
      end
    end

    describe "#engagement_ratio" do
      it "calculates comments to score ratio" do
        article = build(:article, score: 100, comments_count: 50)
        expect(article.engagement_ratio).to eq(50.0)
      end

      it "returns 0 when score is zero" do
        article = build(:article, score: 0, comments_count: 10)
        expect(article.engagement_ratio).to eq(0)
      end
    end

    describe "#discussion_url" do
      it "returns reddit comment url for reddit articles" do
        article = build(:article, source: "reddit", source_name: "programming", external_id: "abc123")
        expect(article.discussion_url).to eq("https://reddit.com/r/programming/comments/abc123")
      end

      it "returns hackernews item url for hackernews articles" do
        article = build(:article, source: "hackernews", external_id: "12345")
        expect(article.discussion_url).to eq("https://news.ycombinator.com/item?id=12345")
      end
    end

    describe "#domain" do
      it "extracts domain from url" do
        article = build(:article, url: "https://www.example.com/article/123")
        expect(article.domain).to eq("example.com")
      end

      it "handles urls without www" do
        article = build(:article, url: "https://example.com/article")
        expect(article.domain).to eq("example.com")
      end

      it "returns nil for invalid urls" do
        article = build(:article, url: "not a url")
        expect(article.domain).to be_nil
      end
    end
  end
end
