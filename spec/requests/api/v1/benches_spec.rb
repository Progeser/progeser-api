# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api/V1/Benches', type: :request do
  let!(:setup) do
    building = buildings(:building1)
    greenhouse = greenhouses(:greenhouse1)
    bench = greenhouse.benches.first

    {
      building_id: building.id,
      greenhouse_id: greenhouse.id,
      bench_id: bench.id,
      bench_name: bench.name,
      bench: bench
    }
  end

  describe 'GET api/v1/buildings/:building_id/greenhouses/:greenhouse_id/benches' do
    context 'when 200' do
      it_behaves_like 'with authenticated grower' do
        it 'gets benches in the given greenhouse with pagination params' do
          get(
            "/api/v1/buildings/#{setup[:building_id]}/greenhouses/#{setup[:greenhouse_id]}/benches",
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
          expect(response.headers['Pagination-Total-Pages']).to eq(2)
          expect(response.headers['Pagination-Total-Count']).to eq(3)
        end
      end
    end

    context 'when 404' do
      it_behaves_like 'with authenticated requester' do
        it 'can\'t get benches' do
          get("/api/v1/buildings/#{setup[:building_id]}/greenhouses/#{setup[:greenhouse_id]}/benches", headers:)

          expect(status).to eq(404)
          expect(response.parsed_body.dig('error', 'message')).not_to be_blank
        end
      end
    end
  end

  describe 'GET api/v1/buildings/:building_id/greenhouses/:greenhouse_id/benches/:id' do
    context 'when 404' do
      it_behaves_like 'with authenticated requester' do
        it 'can\'t get a bench' do
          get(
            "/api/v1/buildings/#{setup[:building_id]}/greenhouses/#{setup[:greenhouse_id]}/benches/#{setup[:bench_id]}", headers:)

          expect(status).to eq(404)
          expect(response.parsed_body.dig('error', 'message')).not_to be_blank
        end
      end
    end
  end

  describe 'POST api/v1/buildings/:building_id/greenhouses/:greenhouse_id/benches' do
    context 'when 404' do
      it_behaves_like 'with authenticated requester' do
        it 'can\'t create a bench' do
          post("/api/v1/buildings/#{setup[:building_id]}/greenhouses/#{setup[:greenhouse_id]}/benches", headers:)

          expect(status).to eq(404)
          expect(response.parsed_body.dig('error', 'message')).not_to be_blank
        end
      end
    end

    context 'when 422' do
      it_behaves_like 'with authenticated grower' do
        it 'can\'t have a negative dimension' do
          post(
            "/api/v1/buildings/#{setup[:building_id]}/greenhouses/#{setup[:greenhouse_id]}/benches",
            headers:,
            params: {
              name: setup[:bench_name],
              dimensions: [-5, 20],
              positions: [10, 10]
            },
            as: :json
          )

          expect(status).to eq(422)
          expect(response.parsed_body.dig('error', 'message')).not_to be_blank
        end
      end

      it_behaves_like 'with authenticated grower' do
        it 'can\'t have a negative position' do
          post(
            "/api/v1/buildings/#{setup[:building_id]}/greenhouses/#{setup[:greenhouse_id]}/benches",
            headers:,
            params: {
              name: setup[:bench_name],
              dimensions: [50, 20],
              positions: [-10, 10]
            },
            as: :json
          )

          expect(status).to eq(422)
          expect(response.parsed_body.dig('error', 'message')).not_to be_blank
        end
      end

      it_behaves_like 'with authenticated grower' do
        before do
          # Créer un banc qui chevauche le banc existant
          post(
            "/api/v1/buildings/#{setup[:building_id]}/greenhouses/#{setup[:greenhouse_id]}/benches",
            headers:,
            params: {
              name: 'Overlapping Bench',
              dimensions: [50, 20],
              positions: [setup[:bench].positions[0], setup[:bench].positions[1]] # même position que le banc existant
            },
            as: :json
          )
        end

        it 'returns an error about overlapping bench' do
          expect(status).to eq(422)
          expect(response.parsed_body.dig('error')).to eq('bench overlaps with an existing bench')
        end
      end
    end
  end

  describe 'PUT api/v1/buildings/:building_id/greenhouses/:greenhouse_id/benches/:id' do
    context 'when 404' do
      it_behaves_like 'with authenticated requester' do
        it 'can\'t update a bench' do
          put(
            "/api/v1/buildings/#{setup[:building_id]}/greenhouses/#{setup[:greenhouse_id]}/benches/#{setup[:bench_id]}",
            headers:
          )

          expect(status).to eq(404)
          expect(response.parsed_body.dig('error', 'message')).not_to be_blank
        end
      end
    end

    context 'when 422' do
      it_behaves_like 'with authenticated grower' do
        it 'can\'t have an area lower than the sum of distributions areas' do
          put(
            "/api/v1/buildings/#{setup[:building_id]}/greenhouses/#{setup[:greenhouse_id]}/benches/#{setup[:bench_id]}",
            headers:,
            params: {
              name: setup[:bench_name],
              dimensions: [25, 30],
              positions: [10, 10]
            },
            as: :json
          )

          expect(status).to eq(422)
          expect(response.parsed_body.dig('error', 'message')).not_to be_blank
        end
      end

      it_behaves_like 'with authenticated grower' do
        before do
          # Tenter la mise à jour d'un banc pour qu'il chevauche un autre banc existant
          put(
            "/api/v1/buildings/#{setup[:building_id]}/greenhouses/#{setup[:greenhouse_id]}/benches/#{setup[:bench_id]}",
            headers:,
            params: {
              name: 'Updated Bench',
              dimensions: [50, 20],
              positions: [setup[:bench].positions[0], setup[:bench].positions[1]] # même position qu'un banc existant
            },
            as: :json
          )
        end

        it 'returns an error about overlapping bench' do
          expect(status).to eq(422)
          expect(response.parsed_body.dig('error')).to eq('bench overlaps with an existing bench')
        end
      end
    end
  end

  describe 'DELETE api/v1/buildings/:building_id/greenhouses/:greenhouse_id/benches/:id' do
    context 'when 403' do
      it_behaves_like 'with authenticated grower' do
        it 'can\'t delete a bench with ongoing requests' do
          delete(
            "/api/v1/buildings/#{setup[:building_id]}/greenhouses/#{setup[:greenhouse_id]}/benches/#{setup[:bench_id]}",
            headers:
          )

          expect(status).to eq(403)
          expect(response.parsed_body.dig('error', 'message')).not_to be_blank
        end
      end
    end

    context 'when 404' do
      it_behaves_like 'with authenticated requester' do
        it 'can\'t delete a bench' do
          delete(
            "/api/v1/buildings/#{setup[:building_id]}/greenhouses/#{setup[:greenhouse_id]}/benches/#{setup[:bench_id]}",
            headers:
          )

          expect(status).to eq(404)
          expect(response.parsed_body.dig('error', 'message')).not_to be_blank
        end
      end
    end

    context 'when 422' do
      it_behaves_like 'with authenticated grower' do
        before do
          setup[:bench].request_distributions.map(&:destroy)
        end

        it 'fails to delete a bench' do
          allow_any_instance_of(Bench).to receive(:destroy).and_return(false)

          delete(
            "/api/v1/buildings/#{setup[:building_id]}/greenhouses/#{setup[:greenhouse_id]}/benches/#{setup[:bench_id]}",
            headers:
          )

          expect(status).to eq(422)
          expect(response.parsed_body.dig('error', 'message')).not_to be_blank
        end
      end
    end
  end
end
