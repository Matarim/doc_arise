# frozen_string_literal: true

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"

  root to: 'dashboard#index'
  get 'dashboard', to: 'dashboard#index'
  get  '/sign-in', to: 'sessions#new', as: :sign_in
  post '/sign-in', to: 'sessions#create'

  get  '/sign-up', to: 'registrations#new', as: :sign_up
  post '/sign-up', to: 'registrations#create'

  get '/auth/:provider/callback', to: 'omniauth_callbacks#create'
  get '/auth/failure', to: 'omniauth_callbacks#failure'

  resource :session
  resources :passwords, param: :token
  resources :registrations, only: %i[new create]
  resources :organizations, only: %i[new create]
  resources :workspaces, only: %i[new create show]
  resources :projects, only: %i[new create show index] do
    resources :api_specifications, only: %i[new create show] do
      resources :api_revisions, only: %i[new create index edit show update] do
        resources :endpoints, only: %i[index show update]
        resources :schemas, only: %i[index show]
        get :documentation, on: :member
      end
    end
  end
end
