# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api/V1/Requests', type: :request do
  let!(:request) { requests(:request1) }
  let!(:id)      { request.id }

  describe 'GET api/v1/requests' do
    context 'when 200' do
      it_behaves_like 'with authenticated grower' do
        it 'gets requests with pagination params' do
          get(
            '/api/v1/requests',
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

        it 'gets requests filtered by status' do
          get(
            '/api/v1/requests',
            headers:,
            params: {
              filter: {
                status: :accepted
              }
            }
          )

          expect(status).to eq(200)
          expect(response.parsed_body.count).to eq(1)
        end

        it 'gets requests sorted by name' do
          get(
            '/api/v1/requests',
            headers:,
            params: {
              sort: 'name'
            }
          )

          expect(status).to eq(200)

          names = response.parsed_body.pluck('name')
          expect(names).to eq(names.sort)
        end

        it 'gets requests sorted in descending order by plant_name' do
          get(
            '/api/v1/requests',
            headers:,
            params: {
              sort: '-plant_name'
            }
          )

          expect(status).to eq(200)

          plant_names = response.parsed_body.pluck('plant_name')
          expect(plant_names).to eq(plant_names.sort.reverse)
        end

        it 'gets requests sorted in descending order by status' do
          get(
            '/api/v1/requests',
            headers:,
            params: {
              sort: '-status'
            }
          )

          expect(status).to eq(200)

          statuses = response.parsed_body.pluck('status')
          expect(statuses).to eq(statuses.sort.reverse)
        end

        it 'gets requests sorted by due_date' do
          get(
            '/api/v1/requests',
            headers:,
            params: {
              sort: 'due_date'
            }
          )

          expect(status).to eq(200)

          due_dates = response.parsed_body.pluck('due_date')
          expect(due_dates).to eq(due_dates.sort)
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
            headers:,
            params: {
              plant_stage_id: plant_stage.id,
              name: 'My request',
              quantity: 150,
              due_date: Date.current + 6.months,
              comment: 'My comment',
              temperature: 'Chaud',
              photoperiod: 4,
              requester_first_name: 'John',
              requester_last_name: 'Doe',
              requester_email: 'john.doe@mail.com'
            }
          )
          expect(status).to eq(201)

          request = Request.last
          expect(response.body).to eq(request.to_blueprint)
          expect(request.handler).to be_nil
          expect(request.plant_stage).to eq(plant_stage)
          expect(request.name).to eq('My request')
          expect(request.plant_name).to eq(plant.name)
          expect(request.plant_stage_name).to eq(plant_stage.name)
          expect(request.status).to eq(:pending)
          expect(request.quantity).to eq(150)
          expect(request.due_date).to eq(Date.current + 6.months)
          expect(request.comment).to eq('My comment')
          expect(request.temperature).to eq('Chaud')
          expect(request.photoperiod).to eq(4)
          expect(request.requester_first_name).to eq('John')
          expect(request.requester_last_name).to eq('Doe')
          expect(request.requester_email).to eq('john.doe@mail.com')
        end

        it 'can create a request from a non-existing plant_stage' do
          post(
            '/api/v1/requests',
            headers:,
            params: {
              name: 'My request',
              plant_name: 'My non-existing plant',
              plant_stage_name: 'My stage name',
              quantity: 150,
              due_date: Date.current + 6.months,
              comment: 'My comment',
              temperature: 'Chaud',
              photoperiod: 4,
              requester_first_name: 'John',
              requester_last_name: 'Doe',
              requester_email: 'john.doe@mail.com'
            }
          )

          expect(status).to eq(201)

          request = Request.last
          expect(response.body).to eq(request.to_blueprint)
          expect(request.handler).to be_nil
          expect(request.plant_stage).to be_nil
          expect(request.name).to eq('My request')
          expect(request.plant_name).to eq('My non-existing plant')
          expect(request.plant_stage_name).to eq('My stage name')
          expect(request.status).to eq(:pending)
          expect(request.quantity).to eq(150)
          expect(request.due_date).to eq(Date.current + 6.months)
          expect(request.comment).to eq('My comment')
          expect(request.temperature).to eq('Chaud')
          expect(request.photoperiod).to eq(4)
          expect(request.requester_first_name).to eq('John')
          expect(request.requester_last_name).to eq('Doe')
          expect(request.requester_email).to eq('john.doe@mail.com')
        end
      end

      it_behaves_like 'without authentication' do
        it 'can create a request from an existing plant_stage' do
          plant = Plant.last
          plant_stage = plant.plant_stages.last

          post(
            '/api/v1/requests',
            headers:,
            params: {
              plant_stage_id: plant_stage.id,
              name: 'My request',
              quantity: 150,
              due_date: Date.current + 6.months,
              comment: 'My comment',
              temperature: 'Chaud',
              photoperiod: 4,
              requester_first_name: 'John',
              requester_last_name: 'Doe',
              requester_email: 'john.doe@mail.com'
            }
          )

          expect(status).to eq(201)

          request = Request.last
          expect(response.body).to eq(request.to_blueprint)
          expect(request.handler).to be_nil
          expect(response.parsed_body['plant_id']).to eq(plant.id)
          expect(request.plant_stage).to eq(plant_stage)
          expect(request.name).to eq('My request')
          expect(request.plant_name).to eq(plant.name)
          expect(request.plant_stage_name).to eq(plant_stage.name)
          expect(request.status).to eq(:pending)
          expect(request.quantity).to eq(150)
          expect(request.due_date).to eq(Date.current + 6.months)
          expect(request.comment).to eq('My comment')
          expect(request.temperature).to eq('Chaud')
          expect(request.photoperiod).to eq(4)
          expect(request.requester_first_name).to eq('John')
          expect(request.requester_last_name).to eq('Doe')
          expect(request.requester_email).to eq('john.doe@mail.com')
        end

        it 'can create a request from a non-existing plant_stage' do
          post(
            '/api/v1/requests',
            headers:,
            params: {
              name: 'My request',
              plant_name: 'My non-existing plant',
              plant_stage_name: 'My stage name',
              quantity: 150,
              due_date: Date.current + 6.months,
              comment: 'My comment',
              temperature: 'Chaud',
              photoperiod: 4,
              requester_first_name: 'John',
              requester_last_name: 'Doe',
              requester_email: 'john.doe@mail.com'
            }
          )

          expect(status).to eq(201)

          request = Request.last
          expect(response.body).to eq(request.to_blueprint)
          expect(request.handler).to be_nil
          expect(response.parsed_body['plant_id']).to be_nil
          expect(request.plant_stage).to be_nil
          expect(request.name).to eq('My request')
          expect(request.plant_name).to eq('My non-existing plant')
          expect(request.plant_stage_name).to eq('My stage name')
          expect(request.status).to eq(:pending)
          expect(request.quantity).to eq(150)
          expect(request.due_date).to eq(Date.current + 6.months)
          expect(request.comment).to eq('My comment')
          expect(request.temperature).to eq('Chaud')
          expect(request.photoperiod).to eq(4)
          expect(request.requester_first_name).to eq('John')
          expect(request.requester_last_name).to eq('Doe')
          expect(request.requester_email).to eq('john.doe@mail.com')
        end
      end
    end

    context 'when 422' do
      it_behaves_like 'with authenticated grower' do
        it 'fails to create a request with missing params' do
          post(
            '/api/v1/requests',
            headers:,
            params: {
              name: nil,
              plant_name: nil,
              plant_stage_name: nil,
              quantity: nil,
              due_date: nil,
              comment: nil,
              temperature: nil,
              photoperiod: nil,
              requester_first_name: nil,
              requester_last_name: nil,
              requester_email: nil
            }
          )

          expect(status).to eq(422)
          expect(response.parsed_body.dig('error', 'message')).not_to be_blank
        end
      end
    end
  end

  describe 'POST api/v1/requests/:id/accept' do
    let!(:request) { requests(:request2) }
    let!(:id)      { request.id }

    context 'when 422' do
      it_behaves_like 'with authenticated grower' do
        it 'can\'t accept a non-pending request' do
          request.update(status: :refused)

          post("/api/v1/requests/#{id}/accept", headers:)

          expect(status).to eq(422)
          expect(response.parsed_body.dig('error', 'message')).not_to be_blank
        end

        it 'can\'t accept a request without distributions' do
          request.update(plant_stage: PlantStage.first)
          request.request_distributions.destroy_all

          post("/api/v1/requests/#{id}/accept", headers:)

          expect(status).to eq(422)
          expect(response.parsed_body.dig('error', 'message')).not_to be_blank
        end

        it 'can\'t accept a request without plant stage' do
          post("/api/v1/requests/#{id}/accept", headers:)

          expect(status).to eq(422)
          expect(response.parsed_body.dig('error', 'message')).not_to be_blank
        end
      end
    end
  end

  describe 'POST api/v1/requests/:id/refuse' do
    let!(:request) { requests(:request2) }
    let!(:id)      { request.id }

    context 'when 422' do
      it_behaves_like 'with authenticated grower' do
        it 'can\'t refuse a non-pending request' do
          request.update(status: :refused)

          post("/api/v1/requests/#{id}/refuse", headers:)

          expect(status).to eq(422)
          expect(response.parsed_body.dig('error', 'message')).not_to be_blank
        end
      end
    end
  end

  describe 'POST api/v1/requests/:id/cancel' do
    let!(:request) { requests(:request2) }
    let!(:id)      { request.id }

    context 'when 422' do
      it_behaves_like 'with authenticated grower' do
        it 'can\'t cancel a non pending, accepted or in_cancelation request' do
          request.update(status: :refused)

          post("/api/v1/requests/#{id}/cancel", headers:)

          expect(status).to eq(422)
          expect(response.parsed_body.dig('error', 'message')).not_to be_blank
        end
      end
    end
  end

  describe 'POST api/v1/requests/:id/complete' do
    let!(:request) { requests(:request2) }
    let!(:id)      { request.id }

    context 'when 422' do
      it_behaves_like 'with authenticated grower' do
        it 'can\'t complete a non-accepted request' do
          post("/api/v1/requests/#{id}/complete", headers:)

          expect(status).to eq(422)
          expect(response.parsed_body.dig('error', 'message')).not_to be_blank
        end
      end
    end
  end

  describe 'DELETE api/v1/requests/:id' do
    context 'when 403' do
      it_behaves_like 'with authenticated grower' do
        it 'can\'t delete a non-pending request' do
          delete("/api/v1/requests/#{id}", headers:)

          expect(status).to eq(403)
          expect(response.parsed_body.dig('error', 'message')).not_to be_blank
        end
      end
    end

    context 'when 401' do
      it_behaves_like 'without authentication' do
        it 'can\'t delete a request' do
          delete("/api/v1/requests/#{id}", headers:)

          expect(status).to eq(401)
        end
      end
    end

    context 'when 422' do
      it_behaves_like 'with authenticated grower' do
        it 'fails to delete a request' do
          request.update(status: :pending)

          allow_any_instance_of(Request).to receive(:destroy).and_return(false)

          delete("/api/v1/requests/#{id}", headers:)

          expect(status).to eq(422)
          expect(response.parsed_body.dig('error', 'message')).not_to be_blank
        end
      end
    end
  end

  describe  'PUT api/v1/requests/:id' do
    context 'when 403' do
      it_behaves_like 'with authenticated grower' do
        it 'can\'t update a request containing request_distributions' do
          put(
            "/api/v1/requests/#{id}",
            headers:,
            params: {
              name: 'My request',
              quantity: 150,
              due_date: Date.current + 6.months,
              comment: 'My comment',
              temperature: 'Chaud',
              photoperiod: 4
            }
          )

          expect(status).to eq(403)
          expect(response.parsed_body.dig('error', 'message')).not_to be_blank
        end
      end
    end

    context 'when 422' do
      let!(:request3) { requests(:request3) }
      let!(:id) { request3.id }

      it_behaves_like 'with authenticated grower' do
        it 'fails to update a request' do
          allow_any_instance_of(Request).to receive(:update).and_return(false)

          put(
            "/api/v1/requests/#{id}",
            headers:,
            params: {
              name: 'My request',
              quantity: 150,
              due_date: Date.current + 6.months,
              comment: 'My comment',
              temperature: 'Chaud',
              photoperiod: 4
            }
          )

          expect(status).to eq(422)
          expect(response.parsed_body.dig('error', 'message')).not_to be_blank
        end
      end
    end

    context 'when 404' do
      it_behaves_like 'with authenticated grower' do
        it 'can\'t update a request that doesn\'t exist' do
          put(
            '/api/v1/requests/999',
            headers:,
            params: {
              name: 'My request',
              quantity: 150,
              due_date: Date.current + 6.months,
              comment: 'My comment',
              temperature: 'Chaud',
              photoperiod: 4
            }
          )

          expect(status).to eq(404)
          expect(response.parsed_body.dig('error', 'message')).not_to be_blank
        end
      end
    end

    context 'when 401' do
      it_behaves_like 'without authentication' do
        it 'can\'t update a request' do
          put(
            "/api/v1/requests/#{id}",
            headers:,
            params: {
              name: 'My request',
              quantity: 150,
              due_date: Date.current + 6.months,
              comment: 'My comment',
              temperature: 'Chaud',
              photoperiod: 4
            }
          )
          expect(status).to eq(401)
        end
      end
    end
  end
end
