# frozen_string_literal: true

require 'acceptance_helper'

resource 'Requests' do
  explanation 'Requests resource'

  header 'Accept',       'application/json'
  header 'Content-Type', 'application/json'

  let!(:user)       { users(:user2) }
  let!(:user_token) { Doorkeeper::AccessToken.create!(resource_owner_id: user.id) }

  let!(:request) { requests(:request1) }
  let!(:id)      { request.id }

  get '/api/v1/requests' do
    parameter :'page[number]',
              "The number of the desired page\n\n" \
              "If used, additional information is returned in the response headers:\n" \
              "`Pagination-Current-Page`: the current page number\n" \
              "`Pagination-Per`: the number of records per page\n" \
              "`Pagination-Total-Pages`: the total number of pages\n" \
              '`Pagination-Total-Count`: the total number of records',
              with_example: true,
              type: :integer,
              default: 1
    parameter :'page[size]',
              "The number of elements in a page\n\n" \
              "If used, additional information is returned in the response headers:\n" \
              "`Pagination-Current-Page`: the current page number\n" \
              "`Pagination-Per`: the number of records per page\n" \
              "`Pagination-Total-Pages`: the total number of pages\n" \
              '`Pagination-Total-Count`: the total number of records',
              with_example: true,
              type: :integer,
              default: FetcheableOnApi.configuration.pagination_default_size
    parameter :'filter[status]',
              'Filter requests by status using case insensitive exact matching',
              with_example: true,
              enum: Request.status.values
    parameter :sort,
              'Sort requests in ascending order by default, unless it is prefixed with a minus',
              enum: %w[id created_at updated_at name plant_name status due_date]

    example 'Get all requests' do
      authentication :basic, "Bearer #{user_token.token}"

      do_request

      expect(status).to eq(200)

      expect(response_body).to eq(Request.to_blueprint)
      expect(JSON.parse(response_body).count).to eq(Request.count)
    end
  end

  get '/api/v1/requests/requests_to_handle_count' do
    example 'Get number of requests to handle' do
      authentication :basic, "Bearer #{user_token.token}"

      do_request

      expect(status).to eq(200)

      parsed_body = JSON.parse(response_body)
      expect(
        parsed_body['pending_requests_count']
      ).to eq(Request.where(status: :pending).count)
      expect(
        parsed_body['in_cancelation_requests_count']
      ).to eq(Request.where(status: :in_cancelation).count)
    end
  end

  get '/api/v1/requests/:id' do
    example 'Get a request' do
      authentication :basic, "Bearer #{user_token.token}"

      do_request

      expect(status).to eq(200)
      expect(response_body).to eq(request.to_blueprint)
    end
  end

  post '/api/v1/requests' do
    parameter :plant_stage_id, 'ID of the requested plant_stage', with_example: true
    parameter :name, 'Name of the request', with_example: true
    parameter :plant_name,
              'Name of the requested plant (ignored if plant_stage_id given)',
              with_example: true
    parameter :plant_stage_name,
              'Name of the requested plant stage (ignored if plant_stage_id given)',
              with_example: true
    parameter :due_date, 'Due date of the request', with_example: true, type: :date
    parameter :quantity, 'Quantity of plants desired', with_example: true, type: :integer
    parameter :comment,
              '(Optional) Free comment to give additional information',
              with_example: true
    parameter :temperature,
              '(Optional) Temperature of cultivation desired',
              with_example: true,
              type: :integer
    parameter :photoperiod,
              '(Optional) Photoperiod of cultivation desired (in hour/day)',
              with_example: true,
              type: :integer
    parameter :requester_first_name,
              'First name of the requester',
              with_example: true,
              type: :string
    parameter :requester_last_name, 'Last name of the requester',
              with_example: true,
              type: :string
    parameter :requester_email, 'Email of the requester',
              with_example: true,
              type: :string

    let(:plant_stage_id) { Plant.last.plant_stages.last.id }
    let(:name)           { 'My request' }
    let(:due_date)       { Date.current + 6.months }
    let(:quantity)       { 150 }
    let(:comment)        { 'The specimens have to be in perfect condition, please be careful!' }
    let(:temperature)    { 'Froid' }
    let(:photoperiod)    { 12 }
    let(:requester_first_name) { 'John' }
    let(:requester_last_name)  { 'Doe' }
    let(:requester_email)      { 'john.doe@mail.com' }

    let(:raw_post) { params.to_json }

    example 'Create a request' do
      authentication :basic, "Bearer #{user_token.token}"
      do_request

      expect(status).to eq(201)

      expect(response_body).to eq(Request.last.to_blueprint)

      response = JSON.parse(response_body)
      expect(response['plant_stage_id']).to eq(plant_stage_id)
      expect(response['plant_id']).to eq(Plant.last.id)
      expect(response['name']).to eq(name)
      expect(response['due_date']).to eq(due_date.strftime('%F'))
      expect(response['quantity']).to eq(quantity)
      expect(response['comment']).to eq(comment)
      expect(response['temperature']).to eq(temperature)
      expect(response['photoperiod']).to eq(photoperiod)
    end
  end

  post '/api/v1/requests/:id/accept' do
    before do
      request.update(status: :pending)
    end

    example 'Accept a request' do
      authentication :basic, "Bearer #{user_token.token}"

      do_request

      expect(status).to eq(200)

      request.reload
      expect(response_body).to eq(request.to_blueprint)
      expect(request.status).to eq(:accepted)
    end
  end

  post '/api/v1/requests/:id/refuse' do
    before do
      request.update(status: :pending)
    end

    example 'Refuse a request' do
      authentication :basic, "Bearer #{user_token.token}"

      do_request

      expect(status).to eq(200)

      request.reload
      expect(response_body).to eq(request.to_blueprint)
      expect(request.status).to eq(:refused)
      expect(request.request_distributions).to be_empty
    end
  end

  post '/api/v1/requests/:id/cancel' do
    before do
      request.update(status: :pending)
    end

    example 'Cancel a request' \
            'If the request is already accepted and the current user is a requester, ' \
            'the request will be set as `in_cancelation`' do
      authentication :basic, "Bearer #{user_token.token}"

      do_request

      expect(status).to eq(200)

      request.reload
      expect(response_body).to eq(request.to_blueprint)
      expect(request.status).to eq(:canceled)
      expect(request.request_distributions).to be_empty
    end
  end

  post '/api/v1/requests/:id/complete' do
    example 'Complete a request' do
      authentication :basic, "Bearer #{user_token.token}"

      do_request

      expect(status).to eq(200)

      request.reload
      expect(response_body).to eq(request.to_blueprint)
      expect(request.status).to eq(:completed)
      expect(request.request_distributions).to be_empty
    end
  end

  delete '/api/v1/requests/:id' do
    before do
      request.update(status: :pending)
    end

    example 'Delete a request' do
      authentication :basic, "Bearer #{user_token.token}"

      do_request

      expect(status).to eq(204)

      expect { request.reload }.to raise_exception(ActiveRecord::RecordNotFound)
    end
  end
end
