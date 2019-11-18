# frozen_string_literal: true

require 'acceptance_helper'

resource 'OAuth Token' do
  explanation 'Doorkeeper Token resource'

  header 'Accept',       'application/json'
  header 'Content-Type', 'application/json'

  let!(:user) { users(:user_1) }

  post '/api/v1/oauth/token' do
    parameter :grant_type,
              'Oauth grant type',
              default: 'password'
    parameter :email,
              'User email',
              required: true,
              with_example: true
    parameter :password,
              'User password',
              required: true,
              with_example: true

    let(:grant_type) { 'password' }
    let(:email)      { user.email }
    let(:password)   { 'password' }

    let(:raw_post) { params.to_json }

    example 'Get new token' do
      do_request

      expect(status).to eq(200)
      expect(JSON.parse(response_body).dig('access_token')).not_to be_blank
      expect(JSON.parse(response_body).dig('refresh_token')).not_to be_blank
    end
  end
end
