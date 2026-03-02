require "rails_helper"

RSpec.describe "Admin Articles", type: :feature do
  before { login_as_admin }

  describe "articles index" do
    it "displays the articles page title" do
      visit admin_articles_path

      expect(page).to have_content("Articles")
    end

    it "displays statistics bar" do
      create_list(:article, 3)
      create(:article, :bookmarked)

      visit admin_articles_path

      expect(page).to have_content("Total")
      expect(page).to have_content("4")
      expect(page).to have_content("Bookmarked")
      expect(page).to have_content("1")
    end

    it "lists articles in a table" do
      create(:article, title: "First Article", score: 100)
      create(:article, title: "Second Article", score: 200)

      visit admin_articles_path

      expect(page).to have_content("First Article")
      expect(page).to have_content("Second Article")
      expect(page).to have_content("100")
      expect(page).to have_content("200")
    end

    it "shows empty state when no articles" do
      visit admin_articles_path

      expect(page).to have_content("No articles found")
    end

    it "displays source badges for reddit articles" do
      create(:article, :from_reddit, source_name: "programming")

      visit admin_articles_path

      expect(page).to have_content("r/programming")
    end

    it "displays source badges for hackernews articles" do
      create(:article, :from_hackernews)

      visit admin_articles_path

      expect(page).to have_content("HN")
    end

    it "shows unread indicator for unread articles" do
      create(:article, read_at: nil)

      visit admin_articles_path

      expect(page).to have_css("span[title='Unread']")
    end

    it "shows read indicator for read articles" do
      create(:article, :read)

      visit admin_articles_path

      expect(page).to have_css("span[title='Read']")
    end

    it "shows bookmark indicator for bookmarked articles" do
      create(:article, :bookmarked)

      visit admin_articles_path

      expect(page).to have_css("span[title='Bookmarked']")
    end
  end

  describe "filtering articles" do
    before do
      create(:article, :from_reddit, title: "Reddit Post", score: 500)
      create(:article, :from_hackernews, title: "HN Story", score: 100)
      create(:article, :bookmarked, title: "Saved Article")
      create(:article, :read, title: "Already Read")
    end

    it "filters by source (reddit) via URL params" do
      visit admin_articles_path(source: "reddit")

      expect(page).to have_content("Reddit Post")
      expect(page).not_to have_content("HN Story")
    end

    it "filters by source (hackernews) via URL params" do
      visit admin_articles_path(source: "hackernews")

      expect(page).to have_content("HN Story")
      expect(page).not_to have_content("Reddit Post")
    end

    it "filters by status (unread) via URL params" do
      visit admin_articles_path(status: "unread")

      expect(page).not_to have_content("Already Read")
    end

    it "filters by status (read) via URL params" do
      visit admin_articles_path(status: "read")

      expect(page).to have_content("Already Read")
    end

    it "filters by status (bookmarked) via URL params" do
      visit admin_articles_path(status: "bookmarked")

      expect(page).to have_content("Saved Article")
    end

    it "filters by minimum score using apply button" do
      visit admin_articles_path

      fill_in "min_score", with: "200"
      click_button "Apply"

      expect(page).to have_content("Reddit Post")
      expect(page).not_to have_content("HN Story")
    end

    it "filters by search query using apply button" do
      visit admin_articles_path

      fill_in "q", with: "Reddit"
      click_button "Apply"

      expect(page).to have_content("Reddit Post")
      expect(page).not_to have_content("HN Story")
    end

    it "clears filters with clear link" do
      visit admin_articles_path(source: "reddit", min_score: 200)

      expect(page).to have_link("Clear")
      click_link "Clear"

      expect(page).to have_current_path(admin_articles_path)
    end

    it "has source filter dropdown" do
      visit admin_articles_path

      expect(page).to have_select("source", options: ["All Sources", "Reddit", "Hacker News", "Lobste.rs", "Dev.to", "Indie Hackers"])
    end

    it "has status filter dropdown" do
      visit admin_articles_path

      expect(page).to have_select("status", options: ["All", "Unread", "Read", "Bookmarked"])
    end

    it "has time filter dropdown" do
      visit admin_articles_path

      expect(page).to have_select("time", options: ["All Time", "Today", "Last 3 Days", "This Week"])
    end

    it "has sort dropdown" do
      visit admin_articles_path

      expect(page).to have_select("sort", options: ["Recent", "Hot", "Top Score", "Most Comments"])
    end
  end

  describe "sorting articles" do
    before do
      create(:article, title: "Old High Score", score: 1000, published_at: 3.days.ago, comments_count: 50)
      create(:article, title: "New Low Score", score: 10, published_at: 1.hour.ago, comments_count: 500)
    end

    it "sorts by recent by default" do
      visit admin_articles_path

      expect(page.body.index("New Low Score")).to be < page.body.index("Old High Score")
    end

    it "sorts by score via URL params" do
      visit admin_articles_path(sort: "score")

      expect(page.body.index("Old High Score")).to be < page.body.index("New Low Score")
    end

    it "sorts by comments via URL params" do
      visit admin_articles_path(sort: "comments")

      expect(page.body.index("New Low Score")).to be < page.body.index("Old High Score")
    end
  end

  describe "time filters" do
    before do
      create(:article, title: "Today Article", published_at: 6.hours.ago)
      create(:article, title: "This Week Article", published_at: 3.days.ago)
      create(:article, title: "Old Article", published_at: 10.days.ago)
    end

    it "filters by today via URL params" do
      visit admin_articles_path(time: "today")

      expect(page).to have_content("Today Article")
      expect(page).not_to have_content("This Week Article")
      expect(page).not_to have_content("Old Article")
    end

    it "filters by this week via URL params" do
      visit admin_articles_path(time: "week")

      expect(page).to have_content("Today Article")
      expect(page).to have_content("This Week Article")
      expect(page).not_to have_content("Old Article")
    end
  end

  describe "viewing article details" do
    let!(:article) { create(:article, title: "Detailed Article", read_at: nil) }

    it "navigates to article show page by clicking title" do
      visit admin_articles_path

      click_link "Detailed Article"

      expect(page).to have_content("Detailed Article")
      expect(page).to have_content("Visit Article")
      expect(page).to have_content("View Discussion")
    end

    it "marks article as read when viewing" do
      expect(article.read?).to be false

      visit admin_article_path(article)

      expect(article.reload.read?).to be true
    end

    it "displays article metadata" do
      visit admin_article_path(article)

      expect(page).to have_content("Source")
      expect(page).to have_content("Score")
      expect(page).to have_content("Comments")
      expect(page).to have_content("Author")
      expect(page).to have_content("Domain")
      expect(page).to have_content("Published")
    end

    it "has back to articles link" do
      visit admin_article_path(article)

      click_link "Back to Articles"

      expect(page).to have_current_path(admin_articles_path)
    end

    it "has external link to source article" do
      visit admin_article_path(article)

      expect(page).to have_link("Visit Article", href: article.url)
    end

    it "has external link to discussion" do
      visit admin_article_path(article)

      expect(page).to have_link("View Discussion", href: article.discussion_url)
    end

    it "has delete button" do
      visit admin_article_path(article)

      expect(page).to have_button("Delete")
    end
  end

  describe "bookmarking articles" do
    let!(:article) { create(:article, bookmarked: false) }

    it "bookmarks an article" do
      visit admin_articles_path

      find("button[title='Bookmark']").click

      expect(article.reload.bookmarked?).to be true
    end

    it "unbookmarks a bookmarked article" do
      article.update!(bookmarked: true, bookmarked_at: Time.current)

      visit admin_articles_path

      find("button[title='Remove bookmark']").click

      expect(article.reload.bookmarked?).to be false
    end
  end

  describe "deleting articles" do
    let!(:article) { create(:article, title: "Article To Delete") }

    it "has a delete button that removes the article" do
      visit admin_article_path(article)

      # Submit the delete form directly (bypassing JS confirm)
      page.find("form[action='#{admin_article_path(article)}'] button[type='submit']").click

      expect(page).to have_current_path(admin_articles_path)
      expect(page).to have_content("Article deleted")
      expect(Article.exists?(article.id)).to be false
    end
  end

  describe "bookmarks page" do
    before do
      create(:article, :bookmarked, title: "Bookmarked Article")
      create(:article, title: "Normal Article")
    end

    it "navigates to bookmarks page via link" do
      visit admin_articles_path

      click_link "Bookmarks (1)"

      expect(page).to have_content("Bookmarks")
      expect(page).to have_content("bookmarked articles")
    end

    it "shows only bookmarked articles" do
      visit bookmarks_admin_articles_path

      expect(page).to have_content("Bookmarked Article")
      expect(page).not_to have_content("Normal Article")
    end

    it "removes bookmark from bookmarks page" do
      article = Article.find_by(title: "Bookmarked Article")

      visit bookmarks_admin_articles_path

      click_button "Remove"

      expect(article.reload.bookmarked?).to be false
    end

    it "shows empty state when no bookmarks" do
      Article.update_all(bookmarked: false)

      visit bookmarks_admin_articles_path

      expect(page).to have_content("No bookmarked articles yet")
    end

    it "has back to articles link" do
      visit bookmarks_admin_articles_path

      click_link "Back to Articles"

      expect(page).to have_current_path(admin_articles_path)
    end
  end

  describe "refresh all button" do
    it "triggers scraping from articles page" do
      expect(ScrapeAllSourcesJob).to receive(:perform_later)

      visit admin_articles_path

      # Submit the refresh form directly (bypassing JS confirm)
      page.find("form[action='#{refresh_admin_articles_path}'] button[type='submit']").click

      expect(page).to have_content("Scraping jobs enqueued")
    end
  end
end
