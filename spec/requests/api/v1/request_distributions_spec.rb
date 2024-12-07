# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api/V1/RequestDistributions', type: :request do
  let!(:request) { requests(:request1) }
  let!(:request_id) { request.id }
  let!(:request_distribution) { request.request_distribution }
  let(:distributions) { request_distribution.distributions }
  let!(:id) { request_distribution.id }

  describe 'GET api/v1/request_distributions' do
    context 'when 200' do
      it_behaves_like 'with authenticated grower' do
        it 'gets request distributions' do
          get(
            '/api/v1/request_distributions',
            headers:
          )

          expect(status).to eq(200)
          expect(response.parsed_body.count).to eq(2)
        end
      end
    end

    context 'when 403' do
      it_behaves_like 'with authenticated requester' do
        it 'can\'t get request distributions' do
          get('/api/v1/request_distributions', headers:)

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
        it 'fails to create a request distribution with missing params' do
          post(
            "/api/v1/requests/#{request_id}/request_distributions",
            headers:,
            params: {
              plant_stage_id: nil
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
        it 'can update a request distribution plant stage' do
          put(
            "/api/v1/request_distributions/#{id}",
            headers:,
            params: {
              plant_stage_id: PlantStage.second.id
            }
          )

          expect(status).to eq(200)

          request_distribution.reload
          expect(response.body).to eq(request_distribution.to_blueprint)
          expect(request_distribution.plant_stage).to eq(PlantStage.second)
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
        it 'can update a request distribution invalid args' do
          put(
            "/api/v1/request_distributions/#{id}",
            headers:,
            params: {
              plant_stage_id: 100
            }
          )

          expect(status).to eq(422)
          expect(response.parsed_body.dig('error', 'message')).not_to be_blank
        end
      end
    end
  end

  describe 'DELETE api/v1/request_distributions/:id' do
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
          request_distribution.distributions.each(&:destroy)
          allow_any_instance_of(RequestDistribution).to receive(:destroy).and_return(false)

          delete("/api/v1/request_distributions/#{id}", headers:)

          expect(status).to eq(422)
          expect(response.parsed_body.dig('error', 'message')).not_to be_blank
        end
      end
    end

    context 'when 403' do
      it_behaves_like 'with authenticated grower' do
        it 'can\'t delete a request distribution if it is associated distributions' do
          delete("/api/v1/request_distributions/#{id}", headers:)

          expect(status).to eq(403)
          expect(response.parsed_body.dig('error', 'message')).not_to be_blank
        end
      end
    end
  end
end
