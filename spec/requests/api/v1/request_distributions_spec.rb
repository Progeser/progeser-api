# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api/V1/RequestDistributions', type: :request do
  let!(:request) { requests(:request1) }
  let!(:request_id) { request.id }
  let!(:distribution) { request.request_distributions.first }
  let!(:id) { distribution.id }

  describe 'GET api/v1/request_distributions' do
    context 'when 200' do
      it_behaves_like 'with authenticated grower' do
        it 'gets request distributions with pagination params' do
          get(
            '/api/v1/request_distributions',
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
  end

  describe 'POST api/v1/requests/:request_id/request_distributions' do
    context 'when 201' do
      it_behaves_like 'with authenticated grower' do
        it 'can create a request distribution given its pot & pot quantity' do
          post(
            "/api/v1/requests/#{request_id}/request_distributions",
            headers:,
            params: {
              bench_id: Bench.first.id,
              plant_stage_id: request.plant_stage_id,
              pot_id: Pot.first.id,
              pot_quantity: 10,
              dimensions: [10, 10],
              positions_on_bench: [150, 150]
            }
          )

          expect(status).to eq(201)

          distribution = RequestDistribution.last
          expect(response.body).to eq(distribution.to_blueprint)
          expect(distribution.request).to eq(request)
          expect(distribution.bench).to eq(Bench.first)
          expect(response.parsed_body['greenhouse_id']).to eq(Bench.first.greenhouse_id)
          expect(distribution.plant_stage).to eq(request.plant_stage)
          expect(distribution.pot).to eq(Pot.first)
          expect(distribution.pot_quantity).to eq(10)
          expect(distribution.dimensions).to eq([10, 10])
          expect(distribution.positions_on_bench).to eq([150, 150])
        end
      end
    end

    context 'when 422' do
      it_behaves_like 'with authenticated grower' do
        it 'fails to create a request distribution with missing params' do
          post(
            "/api/v1/requests/#{request_id}/request_distributions",
            headers:,
            params: {
              bench_id: nil,
              plant_stage_id: nil,
              pot_id: nil,
              pot_quantity: nil,
              dimensions: nil,
              positions_on_bench: nil
            }
          )

          expect(status).to eq(422)
          expect(response.parsed_body.dig('error', 'message')).not_to be_blank
        end

        it 'fails to create a request distribution without enough seeds left to plant' do
          post(
            "/api/v1/requests/#{request_id}/request_distributions",
            headers:,
            params: {
              bench_id: Bench.first.id,
              plant_stage_id: request.plant_stage_id,
              pot_id: Pot.first.id,
              pot_quantity: 500,
              dimensions: [5, 5],
              positions_on_bench: [150, 150]
            }
          )

          expect(status).to eq(422)
          expect(response.parsed_body.dig('error', 'message')).not_to be_blank
        end

        it 'fails to create a request distribution with invalid dimensions' do
          post(
            "/api/v1/requests/#{request_id}/request_distributions",
            headers:,
            params: {
              bench_id: Bench.first.id,
              plant_stage_id: request.plant_stage_id,
              pot_id: Pot.first.id,
              pot_quantity: 5,
              dimensions: [0, -2],
              positions_on_bench: [150, 150]
            }
          )

          expect(status).to eq(422)
          expect(response.parsed_body.dig('error', 'message')).not_to be_blank
        end

        it 'fails to create a request distribution with invalid positions' do
          post(
            "/api/v1/requests/#{request_id}/request_distributions",
            headers:,
            params: {
              bench_id: Bench.first.id,
              plant_stage_id: request.plant_stage_id,
              pot_id: Pot.first.id,
              pot_quantity: 5,
              dimensions: [5, 5],
              positions_on_bench: [-1, -5]
            }
          )

          expect(status).to eq(422)
          expect(response.parsed_body.dig('error', 'message')).not_to be_blank
        end

        it 'fails to create a request distribution with overlapping exists distribution' do
          post(
            "/api/v1/requests/#{request_id}/request_distributions",
            headers:,
            params: {
              bench_id: Bench.first.id,
              plant_stage_id: request.plant_stage_id,
              pot_id: Pot.first.id,
              pot_quantity: 5,
              dimensions: [5, 5],
              positions_on_bench: [10, 10]
            }
          )

          expect(status).to eq(422)
          expect(response.parsed_body.dig('error', 'message')).not_to be_blank
        end

        it 'fails to create a request distribution when it outside bench' do
          post(
            "/api/v1/requests/#{request_id}/request_distributions",
            headers:,
            params: {
              bench_id: Bench.first.id,
              plant_stage_id: request.plant_stage_id,
              pot_id: Pot.first.id,
              pot_quantity: 5,
              dimensions: [5, 5],
              positions_on_bench: [1000, 1000]
            }
          )

          expect(status).to eq(422)
          expect(response.parsed_body.dig('error', 'message')).not_to be_blank
        end
      end
    end
  end

  describe 'PUT api/v1/requests_distributions/:id' do
    context 'when 200' do
      it_behaves_like 'with authenticated grower' do
        it 'can update a request distribution given its pot & pot quantity' do
          put(
            "/api/v1/request_distributions/#{id}",
            headers:,
            params: {
              bench_id: Bench.second.id,
              pot_id: Pot.second.id,
              pot_quantity: 20
            }
          )

          expect(status).to eq(200)

          distribution.reload
          expect(response.body).to eq(distribution.to_blueprint)
          expect(distribution.bench).to eq(Bench.second)
          expect(distribution.pot).to eq(Pot.second)
          expect(distribution.pot_quantity).to eq(20)
        end
      end
    end

    context 'when 422' do
      it_behaves_like 'with authenticated grower' do
        it 'fails to update a request distribution with missing params' do
          put(
            "/api/v1/request_distributions/#{id}",
            headers:,
            params: {
              bench_id: nil,
              plant_stage_id: nil
            }
          )

          expect(status).to eq(422)
          expect(response.parsed_body.dig('error', 'message')).not_to be_blank
        end

        it 'fails to update a request distribution without enough seeds left to plant' do
          put(
            "/api/v1/request_distributions/#{id}",
            headers:,
            params: {
              pot_quantity: 500
            }
          )

          expect(status).to eq(422)
          expect(response.parsed_body.dig('error', 'message')).not_to be_blank
        end

        it 'fails to update a request distribution with invalid dimensions' do
          put(
            "/api/v1/request_distributions/#{id}",
            headers:,
            params: {
              dimensions: [0, -2]
            }
          )

          expect(status).to eq(422)
          expect(response.parsed_body.dig('error', 'message')).not_to be_blank
        end

        it 'fails to update a request distribution with invalid positions' do
          put(
            "/api/v1/request_distributions/#{id}",
            headers:,
            params: {
              positions_on_bench: [-1, -5]
            }
          )

          expect(status).to eq(422)
          expect(response.parsed_body.dig('error', 'message')).not_to be_blank
        end

        it 'fails to update a request distribution when overlapping with another distribution in the same bench' do
          put(
            "/api/v1/request_distributions/#{id}",
            headers:,
            params: {
              positions_on_bench: [60, 60]
            }
          )

          expect(status).to eq(422)
          expect(response.parsed_body.dig('error', 'message')).not_to be_blank
        end

        it 'fails to update a request distribution when it outside bench' do
          put(
            "/api/v1/request_distributions/#{id}",
            headers:,
            params: {
              positions_on_bench: [1000, 1000]
            }
          )

          expect(status).to eq(422)
          expect(response.parsed_body.dig('error', 'message')).not_to be_blank
        end
      end
    end
  end

  describe 'DELETE api/v1/request_distributions/:id' do
    context 'when 403' do
      it_behaves_like 'with authenticated grower' do
        it 'can\'t delete a distribution if it is the last one of the associated request' do
          request.request_distributions.last.destroy

          delete("/api/v1/request_distributions/#{id}", headers:)

          expect(status).to eq(403)
          expect(response.parsed_body.dig('error', 'message')).not_to be_blank
        end
      end
    end

    context 'when 422' do
      it_behaves_like 'with authenticated grower' do
        it 'fails to delete a request distribution' do
          allow_any_instance_of(RequestDistribution).to receive(:destroy).and_return(false)

          delete("/api/v1/request_distributions/#{id}", headers:)

          expect(status).to eq(422)
          expect(response.parsed_body.dig('error', 'message')).not_to be_blank
        end
      end
    end
  end
end
