# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api/V1/Buildings', type: :request do
  let!(:building) { buildings(:building1) }
  let!(:id) { building.id }

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

    context 'when validation fails' do
      it_behaves_like 'with authenticated grower' do
        it 'returns validation error for invalid building data' do
          post(
            '/api/v1/buildings',
            headers:,
            params: { building: { name: '' } }
          )

          expect(status).to eq(422)
          expect(response.parsed_body.dig('error', 'message')).to include('name' => ['doit être rempli(e)'])
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

    context 'when validation fails' do
      it_behaves_like 'with authenticated grower' do
        it 'returns validation error for invalid update data' do
          put(
            "/api/v1/buildings/#{id}",
            headers:,
            params: { building: { name: '' } }
          )

          expect(status).to eq(422)
          expect(response.parsed_body.dig('error', 'message')).to include('name' => ['doit être rempli(e)'])
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

    context 'when validation fails' do
      it_behaves_like 'with authenticated grower' do
        before do
          allow_any_instance_of(Building).to receive(:destroy).and_return(false)
          building.errors.add(:base, 'cannot delete building with ongoing requests')
        end

        it 'returns validation error on destroy' do
          delete("/api/v1/buildings/#{id}", headers:)

          expect(status).to eq(403)
          expect(
            response.parsed_body.dig('error', 'message')
          ).to include('distributions' => ["can't delete a building with ongoing requests"])
        end
      end
    end
  end
end
