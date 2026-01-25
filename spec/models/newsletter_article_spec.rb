require "rails_helper"

RSpec.describe NewsletterArticle, type: :model do
  describe "associations" do
    it "belongs to newsletter" do
      newsletter_article = create(:newsletter_article)
      expect(newsletter_article.newsletter).to be_a(Newsletter)
    end

    it "belongs to article" do
      newsletter_article = create(:newsletter_article)
      expect(newsletter_article.article).to be_a(Article)
    end
  end

  describe "validations" do
    it "validates uniqueness of article within newsletter" do
      newsletter = create(:newsletter)
      article = create(:article)
      create(:newsletter_article, newsletter: newsletter, article: article)

      duplicate = build(:newsletter_article, newsletter: newsletter, article: article)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:newsletter_id]).to include("article already added to this newsletter")
    end

    it "allows same article in different newsletters" do
      article = create(:article)
      newsletter1 = create(:newsletter)
      newsletter2 = create(:newsletter)

      create(:newsletter_article, newsletter: newsletter1, article: article)
      duplicate = build(:newsletter_article, newsletter: newsletter2, article: article)

      expect(duplicate).to be_valid
    end
  end

  describe "position" do
    let(:newsletter) { create(:newsletter) }

    it "auto-assigns position on create" do
      article1 = create(:article)
      article2 = create(:article)

      na1 = create(:newsletter_article, newsletter: newsletter, article: article1)
      na2 = create(:newsletter_article, newsletter: newsletter, article: article2)

      expect(na1.position).to eq(1)
      expect(na2.position).to eq(2)
    end

    it "respects explicit position" do
      article = create(:article)
      na = create(:newsletter_article, newsletter: newsletter, article: article, position: 5)
      expect(na.position).to eq(5)
    end
  end

  describe "#move_up" do
    let(:newsletter) { create(:newsletter) }
    let!(:na1) { create(:newsletter_article, newsletter: newsletter, article: create(:article)) }
    let!(:na2) { create(:newsletter_article, newsletter: newsletter, article: create(:article)) }
    let!(:na3) { create(:newsletter_article, newsletter: newsletter, article: create(:article)) }

    it "swaps position with previous item" do
      na2.move_up
      na1.reload
      na2.reload

      expect(na1.position).to eq(2)
      expect(na2.position).to eq(1)
    end

    it "does nothing if already at top" do
      na1.move_up
      expect(na1.reload.position).to eq(1)
    end
  end

  describe "#move_down" do
    let(:newsletter) { create(:newsletter) }
    let!(:na1) { create(:newsletter_article, newsletter: newsletter, article: create(:article)) }
    let!(:na2) { create(:newsletter_article, newsletter: newsletter, article: create(:article)) }
    let!(:na3) { create(:newsletter_article, newsletter: newsletter, article: create(:article)) }

    it "swaps position with next item" do
      na2.move_down
      na2.reload
      na3.reload

      expect(na2.position).to eq(3)
      expect(na3.position).to eq(2)
    end

    it "does nothing if already at bottom" do
      na3.move_down
      expect(na3.reload.position).to eq(3)
    end
  end
end
