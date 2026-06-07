Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Root route
  root "events#index"

  # Events with nested resources
  resources :events do
    member do
      get :contract
    end
    # Admin: gera o link de preenchimento da lista de padrinhos
    resource :godparent_list, only: [ :create ], module: :admin
    resources :event_owners, path: "owners"
    resources :event_dates, path: "dates"
    resources :guests, only: [ :index, :create, :update, :destroy ] do
      collection do
        post :import
        post :send_rsvp
        get :template
        get :export
        get :print
      end
    end
    resources :event_providers, path: "providers" do
      collection do
        get :export
      end
      member do
        patch :update_details
      end
    end
    resources :manager_checklists, path: "manager_tasks" do
      member do
        patch :toggle_completed
      end
    end
    resources :owner_checklists, path: "owner_tasks" do
      member do
        patch :toggle_completed
      end
    end
    # Cortejo + padrinhos & familiares (só faz sentido para casamentos).
    resource :cortejo, only: [ :show ], controller: "cortejo"
    resources :procession_steps, only: [ :create, :update, :destroy ], path: "cortejo/steps"
    resources :family_members, only: [ :create, :update, :destroy ], path: "cortejo/familiares"
  end

  # Webhook do Twilio (respostas de RSVP no WhatsApp)
  post "webhooks/twilio/whatsapp", to: "webhooks/twilio#whatsapp"

  # Standalone providers
  resources :providers

  # Página pública de preenchimento da lista de padrinhos (protegida por token)
  get    "padrinhos/:token",           to: "public/godparent_lists#show",     as: :godparent_list
  get    "padrinhos/:token/draft",     to: "public/godparent_lists#draft",    as: :draft_godparent_list
  patch  "padrinhos/:token/finalize",  to: "public/godparent_lists#finalize", as: :finalize_godparent_list
  post   "padrinhos/:token/pairs",     to: "public/godparent_pairs#create",   as: :godparent_list_pairs
  patch  "padrinhos/:token/pairs/:id", to: "public/godparent_pairs#update",   as: :godparent_list_pair
  delete "padrinhos/:token/pairs/:id", to: "public/godparent_pairs#destroy"
end
