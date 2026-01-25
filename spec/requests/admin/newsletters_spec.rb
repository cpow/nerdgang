require "rails_helper"

RSpec.describe "Admin::Newsletters", type: :request do
  let(:valid_credentials) do
    ActionController::HttpAuthentication::Basic.encode_credentials("admin", "password")
  end

  let(:headers) { {"HTTP_AUTHORIZATION" => valid_credentials} }

  describe "GET /admin/newsletters" do
    it "requires authentication" do
      get admin_newsletters_path
      expect(response).to have_http_status(:unauthorized)
    end

    it "returns success with valid credentials" do
      get admin_newsletters_path, headers: headers
      expect(response).to have_http_status(:success)
    end

    it "displays newsletters" do
      create(:newsletter, title: "Weekly Digest")
      get admin_newsletters_path, headers: headers

      expect(response.body).to include("Weekly Digest")
    end

    it "does not show discarded newsletters" do
      create(:newsletter, :discarded, title: "Deleted Newsletter")
      get admin_newsletters_path, headers: headers

      expect(response.body).not_to include("Deleted Newsletter")
    end
  end

  describe "GET /admin/newsletters/:id" do
    let(:newsletter) { create(:newsletter) }

    it "requires authentication" do
      get admin_newsletter_path(newsletter)
      expect(response).to have_http_status(:unauthorized)
    end

    it "returns success with valid credentials" do
      get admin_newsletter_path(newsletter), headers: headers
      expect(response).to have_http_status(:success)
    end

    it "displays newsletter articles" do
      article = create(:article, title: "Featured Article")
      create(:newsletter_article, newsletter: newsletter, article: article)

      get admin_newsletter_path(newsletter), headers: headers
      expect(response.body).to include("Featured Article")
    end
  end

  describe "GET /admin/newsletters/new" do
    it "returns success" do
      get new_admin_newsletter_path, headers: headers
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /admin/newsletters" do
    let(:valid_params) { {newsletter: {title: "New Newsletter", slug: "new-newsletter"}} }

    it "creates a newsletter with valid params" do
      expect {
        post admin_newsletters_path, params: valid_params, headers: headers
      }.to change(Newsletter, :count).by(1)
    end

    it "redirects to show page after create" do
      post admin_newsletters_path, params: valid_params, headers: headers
      expect(response).to redirect_to(admin_newsletter_path(Newsletter.last))
    end

    it "renders new with errors for invalid params" do
      post admin_newsletters_path, params: {newsletter: {title: ""}}, headers: headers
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "GET /admin/newsletters/:id/edit" do
    let(:newsletter) { create(:newsletter) }

    it "returns success" do
      get edit_admin_newsletter_path(newsletter), headers: headers
      expect(response).to have_http_status(:success)
    end
  end

  describe "PATCH /admin/newsletters/:id" do
    let(:newsletter) { create(:newsletter, title: "Old Title") }

    it "updates the newsletter" do
      patch admin_newsletter_path(newsletter),
        params: {newsletter: {title: "New Title"}},
        headers: headers

      expect(newsletter.reload.title).to eq("New Title")
    end

    it "redirects to show page after update" do
      patch admin_newsletter_path(newsletter),
        params: {newsletter: {title: "New Title"}},
        headers: headers

      expect(response).to redirect_to(admin_newsletter_path(newsletter))
    end
  end

  describe "DELETE /admin/newsletters/:id" do
    let!(:newsletter) { create(:newsletter) }

    it "soft deletes the newsletter" do
      delete admin_newsletter_path(newsletter), headers: headers

      expect(newsletter.reload.discarded?).to be true
    end

    it "redirects to index" do
      delete admin_newsletter_path(newsletter), headers: headers
      expect(response).to redirect_to(admin_newsletters_path)
    end
  end

  describe "POST /admin/newsletters/:id/publish" do
    let(:newsletter) { create(:newsletter, :draft) }

    it "publishes the newsletter" do
      post publish_admin_newsletter_path(newsletter), headers: headers

      expect(newsletter.reload.published?).to be true
    end

    it "redirects to show page" do
      post publish_admin_newsletter_path(newsletter), headers: headers
      expect(response).to redirect_to(admin_newsletter_path(newsletter))
    end
  end

  describe "POST /admin/newsletters/:id/unpublish" do
    let(:newsletter) { create(:newsletter, :published) }

    it "unpublishes the newsletter" do
      post unpublish_admin_newsletter_path(newsletter), headers: headers

      expect(newsletter.reload.published?).to be false
    end

    it "redirects to show page" do
      post unpublish_admin_newsletter_path(newsletter), headers: headers
      expect(response).to redirect_to(admin_newsletter_path(newsletter))
    end
  end
end
