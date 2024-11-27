Rails.application.routes.draw do
  scope :api do
    scope :v1 do
      use_doorkeeper
    end
  end

  namespace :api do
    namespace :v1 do
      resource :me, controller: 'me', only: %i[show update destroy]

      resource :passwords, only: :update

      resources :account_requests, only: %i[index show create destroy] do
        get :pending_account_requests_count, on: :collection
        post :accept, on: :member
      end

      resources :users, only: :index

      resources :pots, only: %i[index show create update destroy]

      resources :shapes, only: :index

      resources :plants, only: %i[index show create update destroy]

      resources :requests, only: %i[index show create update destroy], shallow: true do
        get :requests_to_handle_count, on: :collection
        post :accept, on: :member
        post :refuse, on: :member
        post :cancel, on: :member
        post :complete, on: :member
        resources :request_distributions, only: %i[index show create update destroy]
      end
      resources :buildings, only: %i[index show create update destroy], shallow: true do
        resources :greenhouses, only: %i[index show create update destroy], shallow: true do
          resources :benches, only: %i[index show create update destroy]
        end
      end
    end
  end
end
