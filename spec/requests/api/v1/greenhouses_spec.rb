# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api/V1/Greenhouses', type: :request do
  let!(:building) { buildings(:building1) }
  let!(:greenhouse) { greenhouses(:greenhouse1) }

  describe 'GET api/v1/greenhouses' do
    context 'when 200' do
      it_behaves_like 'with authenticated grower' do
        it 'gets greenhouses with pagination params' do
          get(
            "/api/v1/buildings/#{building.id}/greenhouses",
            headers:,
            params: {
              page: {
                number: 1,
                size: 2
              }
            }
          )

          expect(status).to eq(200)
          expect(response.parsed_body.count).to eq(1)
          expect(response.headers['Pagination-Current-Page']).to eq(1)
          expect(response.headers['Pagination-Per']).to eq(2)
          expect(response.headers['Pagination-Total-Pages']).to eq(1)
          expect(response.headers['Pagination-Total-Count']).to eq(1)
        end
      end
    end
  end

  describe 'POST api/v1/greenhouses' do
    context 'when 422' do
      it_behaves_like 'with authenticated grower' do
        it 'fails to create a greenhouse with invalid params' do
          post(
            "/api/v1/buildings/#{building.id}/greenhouses",
            headers:,
            params: {
              name: 'foobar',
              width: 100,
              height: -1,
              building_id: building.id
            }
          )

          expect(status).to eq(422)
          expect(response.parsed_body.dig('error', 'message')).not_to be_blank
        end
      end
    end
  end

  describe 'PUT api/v1/greenhouses/:id' do
    context 'when 422' do
      it_behaves_like 'with authenticated grower' do
        it 'fails to update a greenhouse with invalid params' do
          put(
            "/api/v1/greenhouses/#{greenhouse.id}",
            headers:,
            params: {
              name: 'foobar',
              width: -1,
              height: 100,
              building_id: building.id
            }
          )

          expect(status).to eq(422)
          expect(response.parsed_body.dig('error', 'message')).not_to be_blank
        end
      end
    end
  end

  describe 'DELETE api/v1/greenhouses/:id' do
    context 'when 403' do
      it_behaves_like 'with authenticated grower' do
        it 'can\'t delete a greenhouse with ongoing requests' do
          delete("/api/v1/greenhouses/#{greenhouse.id}", headers:)

          expect(status).to eq(403)
          expect(response.parsed_body.dig('error', 'message')).not_to be_blank
        end
      end
    end

    context 'when 422' do
      it_behaves_like 'with authenticated grower' do
        before do
          greenhouse.benches.flat_map(&:request_distributions).map(&:destroy)
        end

        it 'fails to delete a greenhouse' do
          allow_any_instance_of(Greenhouse).to receive(:destroy).and_return(false)

          delete("/api/v1/greenhouses/#{greenhouse.id}", headers:)

          expect(status).to eq(422)
          expect(response.parsed_body.dig('error', 'message')).not_to be_blank
        end
      end
    end
  end
end
