Rails.application.routes.draw do
  root "home#index"

  devise_for :admin_users, path: "admin", skip: [:registrations]

  resources :events, only: [:index, :show] do
    resources :registrations, only: [:new, :create, :show, :edit, :update] do
      member do
        get :invoice # HTML and PDF
        post :send_invoice_email # Send invoice via email
        post :mark_paid # Temporary testing action
      end
    end
  end

  # Payments
  resources :checkouts, only: [:create] do
    collection do
      get :success
      get :cancel
    end
  end

  # Stripe Webhooks
  post "/stripe/webhook", to: "webhooks/stripe#receive"

  # Simple admin dashboard
  namespace :admin do
    resources :events do
      member do
        get :participants
      end
    end
    resources :registrations, only: [:index, :show]
    post :extend_session, to: "sessions#extend"
    root to: "dashboard#index"
  end
end
