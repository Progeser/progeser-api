# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api/V1/Greenhouses', type: :request do
  let!(:greenhouse) { greenhouses(:greenhouse_1) }
  let!(:id)         { greenhouse.id }

  describe 'GET api/v1/greenhouses' do
    context 'when 200' do
      it_behaves_like 'with authenticated grower' do
        it 'get greenhouses with pagination params' do
          get(
            '/api/v1/greenhouses',
            headers: headers,
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
          expect(response.headers.dig('Pagination-Total-Pages')).to eq(1)
          expect(response.headers.dig('Pagination-Total-Count')).to eq(2)
        end
      end
    end

    context 'when 403' do
      it_behaves_like 'with authenticated requester' do
        it 'can\'t get greenhouses as a requester' do
          get('/api/v1/greenhouses', headers: headers)

          expect(status).to eq(403)
          expect(JSON.parse(response.body).dig('error', 'message')).not_to be_blank
        end
      end
    end
  end

  describe 'GET api/v1/greenhouses/:id' do
    context 'when 404' do
      it_behaves_like 'with authenticated requester' do
        it 'can\'t get a greenhouse as a requester' do
          get("/api/v1/greenhouses/#{id}", headers: headers)

          expect(status).to eq(404)
          expect(JSON.parse(response.body).dig('error', 'message')).not_to be_blank
        end
      end
    end
  end

  describe 'POST api/v1/greenhouses' do
    context 'when 403' do
      it_behaves_like 'with authenticated requester' do
        it 'can\'t create a greenhouse as a requester' do
          post('/api/v1/greenhouses', headers: headers)

          expect(status).to eq(403)
          expect(JSON.parse(response.body).dig('error', 'message')).not_to be_blank
        end
      end
    end

    context 'when 422' do
      it_behaves_like 'with authenticated grower' do
        it 'fails to create a greenhouse with invalid params' do
          post(
            '/api/v1/greenhouses',
            headers: headers,
            params: {
              name: 'foobar',
              width: 100,
              height: -1
            }
          )

          expect(status).to eq(422)
          expect(JSON.parse(response.body).dig('error', 'message')).not_to be_blank
        end
      end
    end
  end

  describe 'PUT api/v1/greenhouses/:id' do
    context 'when 404' do
      it_behaves_like 'with authenticated requester' do
        it 'can\'t update a greenhouse as a requester' do
          put("/api/v1/greenhouses/#{id}", headers: headers)

          expect(status).to eq(404)
          expect(JSON.parse(response.body).dig('error', 'message')).not_to be_blank
        end
      end
    end

    context 'when 422' do
      it_behaves_like 'with authenticated grower' do
        it 'fails to update a greenhouse with invalid params' do
          put(
            "/api/v1/greenhouses/#{id}",
            headers: headers,
            params: {
              name: 'foobar',
              width: -1,
              height: 100
            }
          )

          expect(status).to eq(422)
          expect(JSON.parse(response.body).dig('error', 'message')).not_to be_blank
        end
      end
    end
  end

  describe 'DELETE api/v1/greenhouses/:id' do
    context 'when 404' do
      it_behaves_like 'with authenticated requester' do
        it 'can\'t delete a greenhouse as a requester' do
          delete("/api/v1/greenhouses/#{id}", headers: headers)

          expect(status).to eq(404)
          expect(JSON.parse(response.body).dig('error', 'message')).not_to be_blank
        end
      end
    end

    context 'when 422' do
      it_behaves_like 'with authenticated grower' do
        it 'fails to delete a greenhouse' do
          allow_any_instance_of(Greenhouse).to receive(:destroy).and_return(false)

          delete("/api/v1/greenhouses/#{id}", headers: headers)

          expect(status).to eq(422)
          expect(JSON.parse(response.body).dig('error', 'message')).not_to be_blank
        end
      end
    end
  end
end
