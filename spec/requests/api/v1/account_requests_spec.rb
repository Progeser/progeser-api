# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api/V1/AccountRequests', type: :request do
  let!(:account_request) { account_requests(:account_request_1) }
  let!(:id)              { account_request.id }

  describe 'GET api/v1/account_requests' do
    context 'when 200' do
      it_behaves_like 'with authenticated grower' do
        it 'get account requests with pagination params' do
          get(
            '/api/v1/account_requests',
            headers: headers,
            params: {
              page: {
                number: 1,
                size: 2
              }
            }
          )

          expect(status).to eq(200)

          expect(response.parsed_body.count).to eq(2)
          expect(response.headers.dig('Pagination-Current-Page')).to eq(1)
          expect(response.headers.dig('Pagination-Per')).to eq(2)
          expect(response.headers.dig('Pagination-Total-Pages')).to eq(2)
          expect(response.headers.dig('Pagination-Total-Count')).to eq(3)
        end

        it 'get account requests with the right pagination headers when the last page is full' do
          get(
            '/api/v1/account_requests',
            headers: headers,
            params: {
              page: {
                number: 2,
                size: 1
              }
            }
          )

          expect(status).to eq(200)

          expect(response.parsed_body.count).to eq(1)
          expect(response.headers.dig('Pagination-Current-Page')).to eq(2)
          expect(response.headers.dig('Pagination-Per')).to eq(1)
          expect(response.headers.dig('Pagination-Total-Pages')).to eq(3)
          expect(response.headers.dig('Pagination-Total-Count')).to eq(3)
        end
      end
    end

    context 'when 403' do
      it_behaves_like 'with authenticated requester' do
        it 'can\'t get account requests' do
          get('/api/v1/account_requests', headers: headers)

          expect(status).to eq(403)
          expect(response.parsed_body.dig('error', 'message')).not_to be_blank
        end
      end
    end
  end

  describe 'GET api/v1/account_requests/pending_account_requests_count' do
    context 'when 403' do
      it_behaves_like 'with authenticated requester' do
        it 'can\'t get number of pending account requests' do
          get('/api/v1/account_requests/pending_account_requests_count', headers: headers)

          expect(status).to eq(403)
          expect(response.parsed_body.dig('error', 'message')).not_to be_blank
        end
      end
    end
  end

  describe 'GET api/v1/account_requests/:id' do
    context 'when 404' do
      it_behaves_like 'with authenticated requester' do
        it 'can\'t get an account request' do
          get("/api/v1/account_requests/#{id}", headers: headers)

          expect(status).to eq(404)
          expect(response.parsed_body.dig('error', 'message')).not_to be_blank
        end
      end
    end
  end

  describe 'POST api/v1/account_requests' do
    context 'when 422' do
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
        expect(response.parsed_body.dig('error', 'message')).not_to be_blank
      end
    end
  end

  describe 'POST api/v1/account_requests/:id/accept' do
    context 'when 404' do
      it_behaves_like 'with authenticated requester' do
        it 'can\'t accept an account request' do
          post("/api/v1/account_requests/#{id}/accept", headers: headers)

          expect(status).to eq(404)
          expect(response.parsed_body.dig('error', 'message')).not_to be_blank
        end
      end
    end
  end

  describe 'DELETE api/v1/account_requests/:id' do
    context 'when 404' do
      it_behaves_like 'with authenticated requester' do
        it 'can\'t delete an account request' do
          delete("/api/v1/account_requests/#{id}", headers: headers)

          expect(status).to eq(404)
          expect(response.parsed_body.dig('error', 'message')).not_to be_blank
        end
      end
    end

    context 'when 422' do
      it_behaves_like 'with authenticated grower' do
        it 'fails to delete an account request' do
          allow_any_instance_of(AccountRequest).to receive(:destroy).and_return(false)

          delete("/api/v1/account_requests/#{id}", headers: headers)

          expect(status).to eq(422)
          expect(response.parsed_body.dig('error', 'message')).not_to be_blank
        end
      end
    end
  end
end
