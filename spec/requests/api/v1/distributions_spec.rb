# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api/V1/Distributions', type: :request do
  let!(:bench) { benches(:bench1) }
  let!(:greenhouse) { greenhouses(:greenhouse1) }
  let!(:request_distribution) { request_distributions(:request_distribution1) }
  let!(:distribution) { distributions(:distribution1) }

  describe 'GET /api/v1/greenhouses/:greenhouse_id/distributions' do
    context 'when 200' do
      it_behaves_like 'with authenticated grower' do
        it 'gets distributions in the given greenhouse' do
          get(
            "/api/v1/greenhouses/#{greenhouse.id}/distributions",
            headers:
          )

          expect(status).to eq(200)
          expect(response.parsed_body.count).to eq(1)
        end
      end
    end

    context 'when 404' do
      it_behaves_like 'with authenticated requester' do
        it 'can\'t get distributions' do
          get("/api/v1/greenhouses/#{greenhouse.id}/benches", headers:)

          expect(status).to eq(404)
          expect(response.parsed_body.dig('error', 'message')).not_to be_blank
        end
      end
    end
  end

  describe 'POST /api/v1/distributions/:distribution_id' do
    context 'when 403' do
      it_behaves_like 'with authenticated requester' do
        it 'can\'t create a distribution' do
          post('/api/v1/distributions', headers:)

          expect(status).to eq(403)
          expect(response.parsed_body.dig('error', 'message')).not_to be_blank
        end
      end
    end

    context 'when 422' do
      it_behaves_like 'with authenticated grower' do
        it 'fails to create a distribution with missing params' do
          post(
            '/api/v1/distributions',
            headers:,
            params: {}
          )

          expect(status).to eq(422)
          expect(response.parsed_body['seed_quantity']).not_to be_blank
          expect(response.parsed_body['dimensions']).not_to be_blank
          expect(response.parsed_body['positions_on_bench']).not_to be_blank
          expect(response.parsed_body['bench']).not_to be_blank
          expect(response.parsed_body['request_distribution']).not_to be_blank
        end
      end

      it_behaves_like 'with authenticated grower' do
        it 'fails to create a distribution with enough seeds' do
          post(
            '/api/v1/distributions',
            headers:,
            params: {
              seed_quantity: 500,
              dimensions: [5, 5],
              positions_on_bench: [180, 180],
              bench_id: bench.id,
              request_distribution_id: request_distribution.id
            }
          )

          expect(status).to eq(422)
          expect(response.parsed_body['seed_quantity']).not_to be_blank
        end

        it 'fails to create a distribution with dimension less than 0' do
          post(
            '/api/v1/distributions',
            headers:,
            params: {
              seed_quantity: 500,
              dimensions: [0, 0],
              positions_on_bench: [180, 180],
              bench_id: bench.id,
              request_distribution_id: request_distribution.id
            }
          )

          expect(status).to eq(422)
          expect(response.parsed_body['dimensions']).not_to be_blank
        end

        it 'fails to create a distribution with position less than 0' do
          post(
            '/api/v1/distributions',
            headers:,
            params: {
              seed_quantity: 500,
              dimensions: [10, 10],
              positions_on_bench: [-1, -1],
              bench_id: bench.id,
              request_distribution_id: request_distribution.id
            }
          )

          expect(status).to eq(422)
          expect(response.parsed_body['positions_on_bench']).not_to be_blank
        end

        it 'fails to create a distribution with overlaps with an existing distribution' do
          post(
            '/api/v1/distributions',
            headers:,
            params: {
              seed_quantity: 500,
              dimensions: [10, 10],
              positions_on_bench: [0, 0],
              bench_id: bench.id,
              request_distribution_id: request_distribution.id
            }
          )

          expect(status).to eq(422)
          expect(response.parsed_body['positions_on_bench']).not_to be_blank
        end
      end
    end
  end

  describe 'PUT /api/v1/distributions/:distribution_id' do
    context 'when 404' do
      it_behaves_like 'with authenticated requester' do
        it 'can\'t update a distribution' do
          put("/api/v1/distributions/#{distribution.id}", headers:)

          expect(status).to eq(404)
          expect(response.parsed_body.dig('error', 'message')).not_to be_blank
        end
      end
    end

    context 'when 422' do
      it_behaves_like 'with authenticated grower' do
        it 'fails to update a distribution with enough seeds' do
          put(
            "/api/v1/distributions/#{distribution.id}",
            headers:,
            params: {
              seed_quantity: 500
            }
          )

          expect(status).to eq(422)
          expect(response.parsed_body.dig('error', 'message')).not_to be_blank
        end
      end

      it_behaves_like 'with authenticated grower' do
        it 'fails to create a distribution with dimension less than 0' do
          put(
            "/api/v1/distributions/#{distribution.id}",
            headers:,
            params: {
              dimensions: [0, 0]
            }
          )

          expect(status).to eq(422)
          expect(response.parsed_body.dig('error', 'message', 'dimensions')).not_to be_blank
        end
      end

      it_behaves_like 'with authenticated grower' do
        it 'fails to create a distribution with position less than 0' do
          put(
            "/api/v1/distributions/#{distribution.id}",
            headers:,
            params: {
              positions_on_bench: [-1, -1]
            }
          )

          expect(status).to eq(422)
          expect(response.parsed_body.dig('error', 'message', 'positions_on_bench')).not_to be_blank
        end
      end

      it_behaves_like 'with authenticated grower' do
        before do
          post(
            '/api/v1/distributions',
            headers:,
            params: {
              seed_quantity: 10,
              dimensions: [10, 10],
              positions_on_bench: [50, 50],
              bench_id: bench.id,
              request_distribution_id: request_distribution.id
            },
            as: :json
          )
        end

        it 'fails to create a distribution with overlaps with an existing distribution' do
          put(
            "/api/v1/distributions/#{distribution.id}",
            headers:,
            params: {
              positions_on_bench: [51, 51]
            }
          )

          expect(status).to eq(422)
          puts(response.parsed_body)
          expect(response.parsed_body.dig('error', 'message', 'positions_on_bench')).not_to be_blank
        end
      end
    end
  end

  describe 'DELETE /api/v1/distributions/:distribution_id' do
    context 'when 404' do
      it_behaves_like 'with authenticated requester' do
        it 'can\'t delete a request' do
          delete("/api/v1/distributions/#{distribution.id}", headers:)

          expect(status).to eq(404)
          expect(response.parsed_body.dig('error', 'message')).not_to be_blank
        end
      end
    end

    context 'when validation fails' do
      it_behaves_like 'with authenticated grower' do
        before do
          allow_any_instance_of(Distribution).to receive(:destroy).and_return(false)
          distribution.errors.add(:base, 'cannot delete')
        end

        it 'returns validation error on destroy' do
          delete("/api/v1/distributions/#{distribution.id}", headers:)

          expect(status).to eq(422)
          expect(response.parsed_body.dig('error', 'message')).not_to be_blank
        end
      end
    end
  end
end
