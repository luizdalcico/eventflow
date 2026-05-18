Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Root route
  root "events#index"

  # Events with nested resources
  resources :events do
    resources :event_owners, path: "owners"
    resources :event_dates, path: "dates"  
    resources :guests do
      member do
        patch :toggle_godparent
      end
    end
    resources :event_providers, path: "providers" do
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
  end

  # Standalone providers
  resources :providers
end
