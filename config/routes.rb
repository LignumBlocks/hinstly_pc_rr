require 'sidekiq/web'

Rails.application.routes.draw do
  get 'prompts/index'
  get 'prompts/show'
  get 'prompts/new'
  get 'prompts/edit'
  devise_for :users, controllers: {
    omniauth_callbacks: 'users/omniauth_callbacks'
  }
  mount Sidekiq::Web => '/sidekiq'
  mount ActionCable.server => '/cable'

  root 'home#index'

  resource :user, only: %i[edit update destroy]

  resources :validation_sources
  resources :prompts

  resources :channels, only: %i[index create update show edit] do
    collection do
      post :apify_webhook
    end
  end
  resource :channel do
    member do
      post :process_videos
      post :process_videos_test
    end
  end

  resources :hacks, only: [:index]
  resource :hack, only: [:show] do
    member do
      get :download_pdf
    end
  end

  resources :hack_structured_infos

  get '/pages/:page' => 'pages#show', as: :page

  match '/404', to: 'errors#not_found', via: :all
  match '/422', to: 'errors#internal_server_error', via: :all
  match '/500', to: 'errors#internal_server_error', via: :all
end
