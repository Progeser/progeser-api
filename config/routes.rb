Rails.application.routes.draw do
  scope :api do
    scope :v1 do
      use_doorkeeper
    end
  end

  namespace :api do
    namespace :v1 do
      resource :me, controller: 'me', only: %i[show update destroy]

      resource :passwords, only: :update do
        post '/forgot', action: :forgot
        put '/:confirmation_token/reset', action: :reset
      end

      resources :invites, only: %i[index show create destroy] do
        get '/token/:invitation_token', action: :token, on: :collection
        post :retry, on: :member
      end

      resources :account_requests, only: %i[index show create destroy] do
        get :pending_account_requests_count, on: :collection
        post :accept, on: :member
      end

      resources :users, only: :index do
        post '/:invitation_token/create_from_invite',
             on: :collection,
             action: :create_from_invite
        post '/:creation_token/create_from_account_request',
             on: :collection,
             action: :create_from_account_request
      end

      resources :pots, only: %i[index show create update destroy]

      resources :shapes, only: :index

      resources :plants, only: %i[index show create update destroy]

      resources :requests, only: %i[index show create update destroy], shallow: true do
        get :requests_to_handle_count, on: :collection
        post :accept, on: :member
        post :refuse, on: :member
        post :cancel, on: :member
        post :complete, on: :member
        resources :request_distributions, only: %i[show create update destroy]
      end

      resources :request_distributions, only: %i[index]

      resources :buildings, only: %i[index show create update destroy], shallow: true do
        resources :greenhouses, only: %i[index show create update destroy], shallow: true do
          resources :benches, only: %i[index show create update destroy]
        end
      end

      resources :greenhouses, only: [] do
        resources :distributions, only: %i[index]
      end

      resources :distributions, only: %i[show update destroy create]
    end
  end
end
