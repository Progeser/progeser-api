# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api/V1/Benches', type: :request do
  let!(:greenhouse) { greenhouses(:greenhouse1) }
  let!(:bench) { greenhouse.benches.first }

  describe 'GET api/v1/greenhouses/:greenhouse_id/benches' do
    context 'when 200' do
      it_behaves_like 'with authenticated grower' do
        it 'gets benches in the given greenhouse with pagination params' do
          get(
            "/api/v1/greenhouses/#{greenhouse.id}/benches",
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
          get("/api/v1/greenhouses/#{greenhouse.id}/benches", headers:)

          expect(status).to eq(404)
          expect(response.parsed_body.dig('error', 'message')).not_to be_blank
        end
      end
    end
  end

  describe 'GET api/v1/benches/:id' do
    context 'when 404' do
      it_behaves_like 'with authenticated requester' do
        it 'can\'t get a bench' do
          get("/api/v1/benches/#{bench.id}", headers:)

          expect(status).to eq(404)
          expect(response.parsed_body.dig('error', 'message')).not_to be_blank
        end
      end
    end
  end

  describe 'POST api/v1/greenhouses/:greenhouse_id/benches' do
    context 'when 404' do
      it_behaves_like 'with authenticated requester' do
        it 'can\'t create a bench' do
          post("/api/v1/greenhouses/#{greenhouse.id}/benches", headers:)

          expect(status).to eq(404)
          expect(response.parsed_body.dig('error', 'message')).not_to be_blank
        end
      end
    end

    context 'when 422' do
      it_behaves_like 'with authenticated grower' do
        it 'can\'t have a negative dimension' do
          post(
            "/api/v1/greenhouses/#{greenhouse.id}/benches",
            headers:,
            params: {
              name: :bench_name,
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
            "/api/v1/greenhouses/#{greenhouse.id}/benches",
            headers:,
            params: {
              name: :bench_name,
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
          # Create a bench that overlaps the existing bench
          post(
            "/api/v1/greenhouses/#{greenhouse.id}/benches",
            headers:,
            params: {
              name: 'Overlapping Bench',
              dimensions: [50, 20],
              positions: [bench.positions[0], bench.positions[1]] # same position as existing bench
            },
            as: :json
          )
        end

        it 'returns an error about overlapping bench' do
          expect(status).to eq(422)
          expect(response.parsed_body.dig('error', 'message', 'positions').first).to eq('bench overlaps with an existing bench')
        end
      end
    end
  end

  describe 'PUT api/v1/benches/:id' do
    context 'when 404' do
      it_behaves_like 'with authenticated requester' do
        it 'can\'t update a bench' do
          put("/api/v1/benches/#{bench.id}", headers:)

          expect(status).to eq(404)
          expect(response.parsed_body.dig('error', 'message')).not_to be_blank
        end
      end
    end

    context 'when 422' do
      it_behaves_like 'with authenticated grower' do
        it 'can\'t have an area lower than the sum of distributions areas' do
          put(
            "/api/v1/benches/#{bench.id}",
            headers:,
            params: {
              name: :bench_name,
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
          # Attempt to update a bench to overlap another existing bench
          put(
            "/api/v1/benches/#{bench.id}",
            headers:,
            params: {
              name: 'Updated Bench',
              dimensions: [500, 200],
              positions: [bench.positions[0], bench.positions[1]] # same position as an existing bench
            },
            as: :json
          )
        end

        it 'returns an error about overlapping bench' do
          expect(status).to eq(422)
          expect(response.parsed_body.dig('error', 'message', 'positions').first).to eq('bench overlaps with an existing bench')
        end
      end
    end
  end

  describe 'DELETE api/v1/benches/:id' do
    context 'when 403' do
      it_behaves_like 'with authenticated grower' do
        it 'can\'t delete a bench with ongoing requests' do
          delete("/api/v1/benches/#{bench.id}", headers:)

          expect(status).to eq(403)
          expect(response.parsed_body.dig('error', 'message')).not_to be_blank
        end
      end
    end

    context 'when 404' do
      it_behaves_like 'with authenticated requester' do
        it 'can\'t delete a bench' do
          delete("/api/v1/benches/#{bench.id}", headers:)

          expect(status).to eq(404)
          expect(response.parsed_body.dig('error', 'message')).not_to be_blank
        end
      end
    end

    context 'when 422' do
      it_behaves_like 'with authenticated grower' do
        before do
          bench.request_distributions.map(&:destroy)
        end

        it 'fails to delete a bench' do
          allow_any_instance_of(Bench).to receive(:destroy).and_return(false)

          delete("/api/v1/benches/#{bench.id}", headers:)

          expect(status).to eq(422)
          expect(response.parsed_body.dig('error', 'message')).not_to be_blank
        end
      end
    end
  end
end
