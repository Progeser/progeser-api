Rails.application.routes.draw do
  scope :api do
    scope :v1 do
      use_doorkeeper
    end
  end

  namespace :api do
    namespace :v1 do
      resource :me, controller: 'me', only: %i[show update destroy]

      resource :passwords, only: %i[update] do
        post '/forgot', action: :forgot
        put '/:confirmation_token/reset', action: :reset
      end

      resources :invites, only: %i[create destroy] do
        post :retry, on: :member
      end

      resources :account_requests, only: %i[create destroy] do
        post :accept, on: :member
      end

      post '/users/:invitation_token/create_from_invite', to: 'users#create_from_invite'
    end
  end
end
