# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api/V1/AccountRequests', type: :request do
  let!(:user)   { users(:user_2) }
  let!(:token)  { Doorkeeper::AccessToken.create!(resource_owner_id: user.id) }
  let!(:header) do
    { 'Authorization': "Bearer #{token.token}" }
  end

  let!(:requester)   { users(:user_1) }
  let!(:requester_token)  { Doorkeeper::AccessToken.create!(resource_owner_id: requester.id) }
  let!(:requester_header) do
    { 'Authorization': "Bearer #{requester_token.token}" }
  end

  let!(:account_request) { account_requests(:account_request_1) }
  let!(:id)              { account_request.id }

  describe 'POST api/v1/account_requests' do
    context '422' do
      it 'fails to create an account_request with invalid params' do
        post(
          '/api/v1/account_requests',
          params: {
            email: nil,
            first_name: nil,
            last_name: nil,
            comment: nil
          }
        )

        expect(status).to eq(422)
        expect(JSON.parse(response.body).dig('error', 'message')).not_to be_blank
      end
    end
  end

  describe 'POST api/v1/account_requests/:id/accept' do
    context '404' do
      it 'can\'t accept an account request as a requester' do
        post("/api/v1/account_requests/#{id}/accept", headers: requester_header)

        expect(status).to eq(404)
        expect(JSON.parse(response.body).dig('error', 'message')).not_to be_blank
      end
    end
  end

  describe 'DELETE api/v1/account_requests/:id' do
    context '404' do
      it 'can\'t delete an account request as a requester' do
        delete("/api/v1/account_requests/#{id}", headers: requester_header)

        expect(status).to eq(404)
        expect(JSON.parse(response.body).dig('error', 'message')).not_to be_blank
      end
    end

    context '422' do
      it 'fails to delete an account request' do
        allow_any_instance_of(AccountRequest).to receive(:destroy).and_return(false)

        delete("/api/v1/account_requests/#{id}", headers: header)

        expect(status).to eq(422)
        expect(JSON.parse(response.body).dig('error', 'message')).not_to be_blank
      end
    end
  end
end
