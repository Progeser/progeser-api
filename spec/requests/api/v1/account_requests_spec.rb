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

  describe 'GET api/v1/account_requests' do
    context '200' do
      it 'get account requests with pagination params' do
        get(
          '/api/v1/account_requests',
          headers: header,
          params: {
            page: {
              number: 1,
              size: 2
            }
          }
        )

        expect(status).to eq(200)

        expect(JSON.parse(response.body).count).to eq(2)
        expect(response.headers.dig('Pagination-Current-Page')).to eq(1)
        expect(response.headers.dig('Pagination-Per')).to eq(2)
        expect(response.headers.dig('Pagination-Total-Pages')).to eq(2)
        expect(response.headers.dig('Pagination-Total-Count')).to eq(3)
      end

      # The purpose of this test is to insure the issue #20 in the original fetcheable_on_api gem (v 0.3.1) doesn't appear
      # see https://github.com/fabienpiette/fetcheable_on_api/issues/20 for details
      #
      it 'get account requests with the right Pagination-Total-Pages when the last page is full' do
        get(
          '/api/v1/account_requests',
          headers: header,
          params: {
            page: {
              number: 2,
              size: 1
            }
          }
        )

        expect(status).to eq(200)

        expect(JSON.parse(response.body).count).to eq(1)
        expect(response.headers.dig('Pagination-Current-Page')).to eq(2)
        expect(response.headers.dig('Pagination-Per')).to eq(1)
        expect(response.headers.dig('Pagination-Total-Pages')).to eq(3) # not 4!
        expect(response.headers.dig('Pagination-Total-Count')).to eq(3)
      end

      it 'returns 1 as Pagination-Total-Pages when no record is found' do
        AccountRequest.destroy_all

        get(
          '/api/v1/account_requests',
          headers: header,
          params: {
            page: {
              number: 1,
              size: 3
            }
          }
        )

        expect(status).to eq(200)

        expect(JSON.parse(response.body).count).to eq(0)
        expect(response.headers.dig('Pagination-Current-Page')).to eq(1)
        expect(response.headers.dig('Pagination-Per')).to eq(3)
        expect(response.headers.dig('Pagination-Total-Pages')).to eq(1)
        expect(response.headers.dig('Pagination-Total-Count')).to eq(0)
      end
    end

    context '403' do
      it 'can\'t get account requests as a requester' do
        get('/api/v1/account_requests', headers: requester_header)

        expect(status).to eq(403)
        expect(JSON.parse(response.body).dig('error', 'message')).not_to be_blank
      end
    end
  end

  describe 'GET api/v1/account_requests/:id' do
    context '404' do
      it 'can\'t get an account request as a requester' do
        get("/api/v1/account_requests/#{id}", headers: requester_header)

        expect(status).to eq(404)
        expect(JSON.parse(response.body).dig('error', 'message')).not_to be_blank
      end
    end
  end

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
