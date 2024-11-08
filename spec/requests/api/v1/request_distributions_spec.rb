# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api/V1/RequestDistributions', type: :request do
  let!(:request) { requests(:request1) }
  let!(:request_id) { request.id }
  let!(:distribution) { request.request_distributions.first }
  let!(:id) { distribution.id }

  describe 'GET api/v1/requests/:request_id/request_distributions' do
    context 'when 200' do
      it_behaves_like 'with authenticated grower' do
        it 'gets request distributions with pagination params' do
          get(
            "/api/v1/requests/#{request_id}/request_distributions",
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
        it 'can\'t get request distributions' do
          get('/api/v1/requests/2/request_distributions', headers:)

          expect(status).to eq(403)
          expect(response.parsed_body.dig('error', 'message')).not_to be_blank
        end
      end
    end
  end

  describe 'GET api/v1/request_distributions/:id' do
    context 'when 404' do
      it_behaves_like 'with authenticated requester' do
        it 'can\'t get a request distribution' do
          get("/api/v1/request_distributions/#{id}", headers:)

          expect(status).to eq(404)
          expect(response.parsed_body.dig('error', 'message')).not_to be_blank
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
              pot_quantity: 10
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
          expect(distribution.area).not_to be_blank
        end

        it 'can create a request distribution given its area' do
          post(
            "/api/v1/requests/#{request_id}/request_distributions",
            headers:,
            params: {
              bench_id: Bench.first.id,
              plant_stage_id: request.plant_stage_id,
              area: 150
            }
          )

          expect(status).to eq(201)

          distribution = RequestDistribution.last
          expect(response.body).to eq(distribution.to_blueprint)
          expect(distribution.request).to eq(request)
          expect(distribution.bench).to eq(Bench.first)
          expect(response.parsed_body['greenhouse_id']).to eq(Bench.first.greenhouse_id)
          expect(distribution.plant_stage).to eq(request.plant_stage)
          expect(distribution.pot).to be_nil
          expect(distribution.pot_quantity).to be_nil
          expect(distribution.area).to eq(150)
        end
      end
    end

    context 'when 404' do
      it_behaves_like 'with authenticated requester' do
        it 'can\'t create a request distribution' do
          post("/api/v1/requests/#{request_id}/request_distributions", headers:)

          expect(status).to eq(404)
          expect(response.parsed_body.dig('error', 'message')).not_to be_blank
        end
      end
    end

    context 'when 422' do
      it_behaves_like 'with authenticated grower' do
        it 'distributions can\'t have a sum of areas greater than their bench area' do
          dimensions = Bench.first.dimensions
          area = dimensions[0] * dimensions[1]

          post(
            "/api/v1/requests/#{request_id}/request_distributions",
            headers:,
            params: {
              bench_id: Bench.first.id,
              plant_stage_id: request.plant_stage_id,
              area:
            }
          )

          expect(status).to eq(422)
          expect(response.parsed_body.dig('error', 'message')).not_to be_blank
        end

        it 'fails to create a request distribution with missing params' do
          post(
            "/api/v1/requests/#{request_id}/request_distributions",
            headers:,
            params: {
              bench_id: nil,
              plant_stage_id: nil,
              area: nil
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
          expect(distribution.area).not_to be_blank
        end

        it 'can update a request distribution given its area' do
          put(
            "/api/v1/request_distributions/#{id}",
            headers:,
            params: {
              bench_id: Bench.second.id,
              area: 100
            }
          )

          expect(status).to eq(200)

          distribution.reload
          expect(response.body).to eq(distribution.to_blueprint)
          expect(distribution.bench).to eq(Bench.second)
          expect(distribution.area).to eq(100)
        end
      end
    end

    context 'when 404' do
      it_behaves_like 'with authenticated requester' do
        it 'can\'t update a request distribution' do
          put("/api/v1/request_distributions/#{id}", headers:)

          expect(status).to eq(404)
          expect(response.parsed_body.dig('error', 'message')).not_to be_blank
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
              plant_stage_id: nil,
              area: nil
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

    context 'when 404' do
      it_behaves_like 'with authenticated requester' do
        it 'can\'t delete a request distribution' do
          delete("/api/v1/request_distributions/#{id}", headers:)

          expect(status).to eq(404)
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
