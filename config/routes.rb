Rails.application.routes.draw do
  # Admin namespace
  namespace :admin do
    root to: "dashboard#index"

    resources :articles, only: [:index, :show, :destroy] do
      member do
        post :toggle_bookmark
        post :mark_read
      end
      collection do
        post :refresh
        get :bookmarks
      end
    end
  end

  # Health check
  get "up" => "rails/health#show", :as => :rails_health_check

  # Root redirects to admin for now
  root to: redirect("/admin")
end
