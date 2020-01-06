# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api/V1/Shapes', type: :request do
  let!(:user)  { users(:user_2) }
  let!(:token) { Doorkeeper::AccessToken.create!(resource_owner_id: user.id) }
  let!(:header) do
    { 'Authorization': "Bearer #{token.token}" }
  end

  let!(:requester)       { users(:user_1) }
  let!(:requester_token) { Doorkeeper::AccessToken.create!(resource_owner_id: requester.id) }
  let!(:requester_header) do
    { 'Authorization': "Bearer #{requester_token.token}" }
  end

  describe 'GET api/v1/shapes' do
    context '403' do
      it 'can\'t get shapes as a requester' do
        get('/api/v1/shapes', headers: requester_header)

        expect(status).to eq(403)
        expect(JSON.parse(response.body).dig('error', 'message')).not_to be_blank
      end
    end
  end
end
