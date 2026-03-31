Rails.application.routes.draw do
  # Admin namespace
  namespace :admin do
    root to: "dashboard#index"

    resources :articles, only: [:index, :show, :destroy] do
      member do
        post :toggle_bookmark
        post :mark_read
        post :add_to_newsletter
      end
      collection do
        post :refresh
        get :bookmarks
      end
    end

    resources :newsletters do
      member do
        post :publish
        post :unpublish
        post :send_newsletter
        get :preview
      end
    end

    resources :newsletter_articles, only: [:create, :destroy] do
      member do
        post :move_up
        post :move_down
      end
    end

    resources :subscribers, only: [:index]
  end

  # Public newsletters
  resources :newsletters, only: [:index, :show], param: :slug
  resources :subscribers, only: [:create]

  # Unsubscribe
  get "unsubscribe/:token", to: "unsubscribes#show", as: :unsubscribe

  # Webhooks
  post "webhooks/resend", to: "webhooks/resend#create"

  # Health check
  get "up" => "rails/health#show", :as => :rails_health_check

  # Root redirects to newsletters for now
  root to: redirect("/newsletters")
end
