# frozen_string_literal: true

require 'acceptance_helper'

resource 'OAuth Tokens' do
  explanation 'Doorkeeper Tokens resource'

  header 'Accept',       'application/json'
  header 'Content-Type', 'application/json'

  let!(:user) { users(:user1) }

  post '/api/v1/oauth/token' do
    parameter :grant_type, 'Oauth grant type', with_example: true
    parameter :client_id, 'Oauth client ID', with_example: true
    parameter :email, 'User email', with_example: true
    parameter :password, 'User password', with_example: true

    let(:grant_type) { 'password' }
    let(:client_id)  { oauth_applications(:application).uid }
    let(:email)      { user.email }
    let(:password)   { 'password' }

    let(:raw_post) { params.to_json }

    example 'Get a new token' do
      do_request

      expect(status).to eq(200)

      response = JSON.parse(response_body)
      expect(response['access_token']).not_to be_blank
      expect(response['refresh_token']).not_to be_blank
    end
  end
end
