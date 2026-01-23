require "rails_helper"

RSpec.describe "Admin Dashboard", type: :feature do
  before { login_as_admin }

  describe "viewing the dashboard" do
    it "displays the dashboard title" do
      visit admin_root_path

      expect(page).to have_content("Dashboard")
    end

    it "displays statistics cards" do
      create_list(:article, 3, :from_reddit)
      create_list(:article, 2, :from_hackernews)

      visit admin_root_path

      expect(page).to have_content("Total Articles")
      expect(page).to have_content("5")
      expect(page).to have_content("Reddit")
      expect(page).to have_content("3")
      expect(page).to have_content("Hacker News")
      expect(page).to have_content("2")
    end

    it "displays today count" do
      create(:article, published_at: 6.hours.ago)
      create(:article, published_at: 2.days.ago)

      visit admin_root_path

      expect(page).to have_content("Today")
    end

    it "displays this week count" do
      visit admin_root_path

      expect(page).to have_content("This Week")
    end

    it "displays last scrape time" do
      create(:article, scraped_at: Time.current)

      visit admin_root_path

      expect(page).to have_content("Last Scrape")
    end

    it "displays recent articles section" do
      create(:article, title: "Recent Test Article", published_at: 1.hour.ago)

      visit admin_root_path

      expect(page).to have_content("Recent Articles")
      expect(page).to have_content("Recent Test Article")
    end

    it "displays top articles section" do
      create(:article, title: "Top Scoring Article", score: 1000, published_at: 2.days.ago)

      visit admin_root_path

      expect(page).to have_content("Top Articles This Week")
      expect(page).to have_content("Top Scoring Article")
    end

    it "shows empty state when no articles exist" do
      visit admin_root_path

      expect(page).to have_content("No articles yet")
    end

    it "links to article show pages" do
      article = create(:article, title: "Linked Article")

      visit admin_root_path

      expect(page).to have_link("Linked Article", href: admin_article_path(article))
    end

    it "navigates to article show page when clicking title" do
      article = create(:article, title: "Clickable Article")

      visit admin_root_path
      first(:link, "Clickable Article").click

      expect(page).to have_current_path(admin_article_path(article))
    end
  end

  describe "navigation" do
    it "has working navigation links" do
      visit admin_root_path

      click_link "Articles"
      expect(page).to have_current_path(admin_articles_path)

      click_link "Dashboard"
      expect(page).to have_current_path(admin_root_path)
    end

    it "highlights current page in navigation" do
      visit admin_root_path

      # Dashboard link should be highlighted
      expect(page).to have_css("a.border-gray-900", text: "Dashboard")
    end
  end

  describe "refresh all button" do
    it "exists in the navigation" do
      visit admin_root_path

      expect(page).to have_button("Refresh All")
    end

    it "triggers scraping jobs when clicked" do
      expect(ScrapeAllSourcesJob).to receive(:perform_later)

      visit admin_root_path

      # Submit the refresh form directly (bypassing JS confirm)
      page.find("form[action='#{refresh_admin_articles_path}'] button[type='submit']").click

      expect(page).to have_content("Scraping jobs enqueued")
    end
  end
end
