require "rails_helper"

RSpec.describe "Admin Dark Mode", type: :feature do
  before { login_as_admin }

  describe "dark mode toggle button" do
    it "exists on dashboard page" do
      visit admin_root_path

      expect(page).to have_css("button[title='Toggle dark mode']")
    end

    it "exists on articles page" do
      visit admin_articles_path

      expect(page).to have_css("button[title='Toggle dark mode']")
    end

    it "exists on bookmarks page" do
      visit bookmarks_admin_articles_path

      expect(page).to have_css("button[title='Toggle dark mode']")
    end

    it "exists on article show page" do
      article = create(:article)
      visit admin_article_path(article)

      expect(page).to have_css("button[title='Toggle dark mode']")
    end
  end

  describe "dark mode default state" do
    it "has dark class on html element by default" do
      visit admin_root_path

      # The HTML element should have class="dark" by default
      expect(page).to have_css("html.dark")
    end
  end
end
