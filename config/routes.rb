Rails.application.routes.draw do
  devise_for :users, controllers: {
    omniauth_callbacks: 'users/omniauth_callbacks',
  }
  root "home#index"

  resource :user, only: %i[edit update destroy]
  resources :channels, only: [:index, :create, :update, :show, :edit]
  resources :validation_sources

  resource :channel do
    member do
      post :process_videos
    end
  end

  get "/pages/:page" => "pages#show", as: :page

  match '/404', to: 'errors#not_found', via: :all
  match '/422', to: 'errors#internal_server_error', via: :all
  match '/500', to: 'errors#internal_server_error', via: :all
end
