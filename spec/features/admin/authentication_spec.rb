require "rails_helper"

RSpec.describe "Admin Authentication", type: :feature do
  describe "without authentication" do
    it "returns unauthorized for dashboard" do
      visit admin_root_path

      expect(page.status_code).to eq(401)
    end

    it "returns unauthorized for articles" do
      visit admin_articles_path

      expect(page.status_code).to eq(401)
    end

    it "returns unauthorized for bookmarks" do
      visit bookmarks_admin_articles_path

      expect(page.status_code).to eq(401)
    end
  end

  describe "with valid credentials" do
    before { login_as_admin }

    it "allows access to dashboard" do
      visit admin_root_path

      expect(page.status_code).to eq(200)
      expect(page).to have_content("Dashboard")
    end

    it "allows access to articles" do
      visit admin_articles_path

      expect(page.status_code).to eq(200)
      expect(page).to have_content("Articles")
    end
  end
end
