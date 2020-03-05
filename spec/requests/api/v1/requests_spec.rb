# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api/V1/Requests', type: :request do
  let!(:request) { requests(:request_1) }
  let!(:id)      { request.id }

  describe 'GET api/v1/requests' do
    context 'when 200' do
      it_behaves_like 'with authenticated grower' do
        it 'gets requests with pagination params' do
          get(
            '/api/v1/requests',
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

        it 'gets requests filtered by status' do
          get(
            '/api/v1/requests',
            headers: headers,
            params: {
              filter: {
                status: :accepted
              }
            }
          )

          expect(status).to eq(200)
          expect(JSON.parse(response.body).count).to eq(1)
        end
      end

      it_behaves_like 'with authenticated requester' do
        it 'can get my requests' do
          get('/api/v1/requests', headers: headers)

          expect(status).to eq(200)
          expect(JSON.parse(response.body).count).to eq(1)
        end
      end
    end
  end

  describe 'GET api/v1/requests/:id' do
    context 'when 404' do
      it_behaves_like 'with authenticated requester' do
        it 'can\'t get a request of another author' do
          get("/api/v1/requests/#{id}", headers: headers)

          expect(status).to eq(404)
          expect(JSON.parse(response.body).dig('error', 'message')).not_to be_blank
        end
      end
    end
  end

  describe 'POST api/v1/requests' do
    context 'when 201' do
      it_behaves_like 'with authenticated grower' do
        it 'can create a request from an existing plant_stage' do
          plant = Plant.last
          plant_stage = plant.plant_stages.last

          post(
            '/api/v1/requests',
            headers: headers,
            params: {
              plant_stage_id: plant_stage.id,
              name: 'My request',
              quantity: 150,
              due_date: Date.current + 6.months,
              comment: 'My comment',
              temperature: 10,
              photoperiod: 4
            }
          )

          expect(status).to eq(201)

          request = Request.last
          expect(response.body).to eq(request.to_blueprint)
          expect(request.author).to eq(user)
          expect(request.handler).to eq(nil)
          expect(request.plant_stage).to eq(plant_stage)
          expect(request.name).to eq('My request')
          expect(request.plant_name).to eq(plant.name)
          expect(request.stage_name).to eq(plant_stage.name)
          expect(request.status).to eq(:pending)
          expect(request.quantity).to eq(150)
          expect(request.due_date).to eq(Date.current + 6.months)
          expect(request.comment).to eq('My comment')
          expect(request.temperature).to eq(10)
          expect(request.photoperiod).to eq(4)
        end

        it 'can create a request from a non-existing plant_stage' do
          post(
            '/api/v1/requests',
            headers: headers,
            params: {
              name: 'My request',
              plant_name: 'My non-existing plant',
              stage_name: 'My stage name',
              quantity: 150,
              due_date: Date.current + 6.months,
              comment: 'My comment',
              temperature: 10,
              photoperiod: 4
            }
          )

          expect(status).to eq(201)

          request = Request.last
          expect(response.body).to eq(request.to_blueprint)
          expect(request.author).to eq(user)
          expect(request.handler).to eq(nil)
          expect(request.plant_stage).to eq(nil)
          expect(request.name).to eq('My request')
          expect(request.plant_name).to eq('My non-existing plant')
          expect(request.stage_name).to eq('My stage name')
          expect(request.status).to eq(:pending)
          expect(request.quantity).to eq(150)
          expect(request.due_date).to eq(Date.current + 6.months)
          expect(request.comment).to eq('My comment')
          expect(request.temperature).to eq(10)
          expect(request.photoperiod).to eq(4)
        end
      end

      it_behaves_like 'with authenticated requester' do
        it 'can create a request from an existing plant_stage' do
          plant = Plant.last
          plant_stage = plant.plant_stages.last

          post(
            '/api/v1/requests',
            headers: headers,
            params: {
              plant_stage_id: plant_stage.id,
              name: 'My request',
              quantity: 150,
              due_date: Date.current + 6.months,
              comment: 'My comment',
              temperature: 10,
              photoperiod: 4
            }
          )

          expect(status).to eq(201)

          request = Request.last
          expect(response.body).to eq(request.to_blueprint)
          expect(request.author).to eq(user)
          expect(request.handler).to eq(nil)
          expect(request.plant_stage).to eq(plant_stage)
          expect(request.name).to eq('My request')
          expect(request.plant_name).to eq(plant.name)
          expect(request.stage_name).to eq(plant_stage.name)
          expect(request.status).to eq(:pending)
          expect(request.quantity).to eq(150)
          expect(request.due_date).to eq(Date.current + 6.months)
          expect(request.comment).to eq('My comment')
          expect(request.temperature).to eq(10)
          expect(request.photoperiod).to eq(4)
        end

        it 'can create a request from a non-existing plant_stage' do
          post(
            '/api/v1/requests',
            headers: headers,
            params: {
              name: 'My request',
              plant_name: 'My non-existing plant',
              stage_name: 'My stage name',
              quantity: 150,
              due_date: Date.current + 6.months,
              comment: 'My comment',
              temperature: 10,
              photoperiod: 4
            }
          )

          expect(status).to eq(201)

          request = Request.last
          expect(response.body).to eq(request.to_blueprint)
          expect(request.author).to eq(user)
          expect(request.handler).to eq(nil)
          expect(request.plant_stage).to eq(nil)
          expect(request.name).to eq('My request')
          expect(request.plant_name).to eq('My non-existing plant')
          expect(request.stage_name).to eq('My stage name')
          expect(request.status).to eq(:pending)
          expect(request.quantity).to eq(150)
          expect(request.due_date).to eq(Date.current + 6.months)
          expect(request.comment).to eq('My comment')
          expect(request.temperature).to eq(10)
          expect(request.photoperiod).to eq(4)
        end
      end
    end

    context 'when 422' do
      it_behaves_like 'with authenticated grower' do
        it 'fails to create a request with missing params' do
          post(
            '/api/v1/requests',
            headers: headers,
            params: {
              name: nil,
              plant_name: nil,
              stage_name: nil,
              quantity: nil,
              due_date: nil,
              comment: nil,
              temperature: nil,
              photoperiod: nil
            }
          )

          expect(status).to eq(422)
          expect(JSON.parse(response.body).dig('error', 'message')).not_to be_blank
        end
      end
    end
  end

  describe 'PUT api/v1/requests/:id' do
    context 'when 404' do
      it_behaves_like 'with authenticated requester' do
        it 'can\'t update a request of another author' do
          put("/api/v1/requests/#{id}", headers: headers)

          expect(status).to eq(404)
          expect(JSON.parse(response.body).dig('error', 'message')).not_to be_blank
        end
      end
    end

    context 'when 422' do
      it_behaves_like 'with authenticated grower' do
        it 'fails to update a request with missing params' do
          put(
            "/api/v1/requests/#{id}",
            headers: headers,
            params: {
              name: nil,
              plant_name: nil,
              stage_name: nil,
              quantity: nil,
              due_date: nil,
              comment: nil,
              temperature: nil,
              photoperiod: nil
            }
          )

          expect(status).to eq(422)
          expect(JSON.parse(response.body).dig('error', 'message')).not_to be_blank
        end
      end
    end
  end

  describe 'POST api/v1/requests/:id/accept' do
    let!(:request) { requests(:request_2) }
    let!(:id)      { request.id }

    context 'when 403' do
      it_behaves_like 'with authenticated requester' do
        it 'can\'t accept a request' do
          post("/api/v1/requests/#{id}/accept", headers: headers)

          expect(status).to eq(403)
          expect(JSON.parse(response.body).dig('error', 'message')).not_to be_blank
        end
      end
    end

    context 'when 422' do
      it_behaves_like 'with authenticated grower' do
        before do
          request.update(status: :accepted)
        end

        it 'can\'t accept a non-pending request' do
          post("/api/v1/requests/#{id}/accept", headers: headers)

          expect(status).to eq(422)
          expect(JSON.parse(response.body).dig('error', 'message')).not_to be_blank
        end
      end
    end
  end

  describe 'POST api/v1/requests/:id/refuse' do
    let!(:request) { requests(:request_2) }
    let!(:id)      { request.id }

    context 'when 403' do
      it_behaves_like 'with authenticated requester' do
        it 'can\'t refuse a request' do
          post("/api/v1/requests/#{id}/refuse", headers: headers)

          expect(status).to eq(403)
          expect(JSON.parse(response.body).dig('error', 'message')).not_to be_blank
        end
      end
    end

    context 'when 422' do
      it_behaves_like 'with authenticated grower' do
        before do
          request.update(status: :accepted)
        end

        it 'can\'t refuse a non-pending request' do
          post("/api/v1/requests/#{id}/refuse", headers: headers)

          expect(status).to eq(422)
          expect(JSON.parse(response.body).dig('error', 'message')).not_to be_blank
        end
      end
    end
  end

  describe 'POST api/v1/requests/:id/cancel' do
    let!(:request) { requests(:request_2) }
    let!(:id)      { request.id }

    context 'when 200' do
      it_behaves_like 'with authenticated requester' do
        it 'can cancel a pending request' do
          post("/api/v1/requests/#{id}/cancel", headers: headers)

          expect(status).to eq(200)

          request.reload
          expect(response.body).to eq(request.to_blueprint)
          expect(request.status).to eq(:canceled)
        end

        it 'can ask to cancel an accepted request' do
          request.update(status: :accepted)

          post("/api/v1/requests/#{id}/cancel", headers: headers)

          expect(status).to eq(200)

          request.reload
          expect(response.body).to eq(request.to_blueprint)
          expect(request.status).to eq(:in_cancelation)
        end
      end
    end

    context 'when 422' do
      it_behaves_like 'with authenticated grower' do
        before do
          request.update(status: :accepted)
        end

        it 'can\'t cancel a non pending or in_cancelation request' do
          post("/api/v1/requests/#{id}/cancel", headers: headers)

          expect(status).to eq(422)
          expect(JSON.parse(response.body).dig('error', 'message')).not_to be_blank
        end
      end
    end
  end

  describe 'DELETE api/v1/requests/:id' do
    context 'when 403' do
      it_behaves_like 'with authenticated grower' do
        it 'can\'t delete a non-pending request' do
          delete("/api/v1/requests/#{id}", headers: headers)

          expect(status).to eq(403)
          expect(JSON.parse(response.body).dig('error', 'message')).not_to be_blank
        end
      end
    end

    context 'when 404' do
      it_behaves_like 'with authenticated requester' do
        it 'can\'t delete a request' do
          delete("/api/v1/requests/#{id}", headers: headers)

          expect(status).to eq(404)
          expect(JSON.parse(response.body).dig('error', 'message')).not_to be_blank
        end
      end
    end

    context 'when 422' do
      it_behaves_like 'with authenticated grower' do
        it 'fails to delete a request' do
          request.update(status: :pending)

          allow_any_instance_of(Request).to receive(:destroy).and_return(false)

          delete("/api/v1/requests/#{id}", headers: headers)

          expect(status).to eq(422)
          expect(JSON.parse(response.body).dig('error', 'message')).not_to be_blank
        end
      end
    end
  end
end
