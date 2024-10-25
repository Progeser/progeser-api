# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api/V1/Buildings', type: :request do
  let!(:building) { buildings(:building1) }
  let!(:id)       { building.id }

  describe 'GET api/v1/buildings' do
    context 'when 200' do
      it_behaves_like 'with authenticated grower' do
        it 'gets buildings with pagination params' do
          get(
            '/api/v1/buildings',
            headers:,
            params: {
              page: {
                number: 1,
                size: 2
              }
            }
          )

          expect(status).to eq(200)
          expect(response.parsed_body.count).to eq(2)
          expect(response.headers['Pagination-Current-Page']).to eq(1)
          expect(response.headers['Pagination-Per']).to eq(2)
          expect(response.headers['Pagination-Total-Pages']).to eq(1)
          expect(response.headers['Pagination-Total-Count']).to eq(2)
        end
      end
    end

    context 'when 403' do
      it_behaves_like 'with authenticated requester' do
        it 'can\'t get buildings' do
          get('/api/v1/buildings', headers:)

          expect(status).to eq(403)
          expect(response.parsed_body.dig('error', 'message')).not_to be_blank
        end
      end
    end
  end

  describe 'GET api/v1/buildings/:id' do
    context 'when 404' do
      it_behaves_like 'with authenticated requester' do
        it 'can\'t get a building' do
          get("/api/v1/buildings/#{id}", headers:)

          expect(status).to eq(404)
          expect(response.parsed_body.dig('error', 'message')).not_to be_blank
        end
      end
    end
  end

  describe 'POST api/v1/buildings' do
    context 'when 403' do
      it_behaves_like 'with authenticated requester' do
        it 'can\'t create a building' do
          post('/api/v1/buildings', headers:)

          expect(status).to eq(403)
          expect(response.parsed_body.dig('error', 'message')).not_to be_blank
        end
      end
    end
  end

  describe 'PUT api/v1/buildings/:id' do
    context 'when 404' do
      it_behaves_like 'with authenticated requester' do
        it 'can\'t update a building' do
          put("/api/v1/buildings/#{id}", headers:)

          expect(status).to eq(404)
          expect(response.parsed_body.dig('error', 'message')).not_to be_blank
        end
      end
    end
  end

  describe 'DELETE api/v1/buildings/:id' do
    context 'when 404' do
      it_behaves_like 'with authenticated requester' do
        it 'can\'t delete a building' do
          delete("/api/v1/buildings/#{id}", headers:)
          expect(status).to eq(404)
          expect(response.parsed_body.dig('error', 'message')).not_to be_blank
        end
      end
    end
  end
end
