# frozen_string_literal: true

require 'acceptance_helper'

resource 'Requests' do
  explanation 'Requests resource'

  header 'Accept',       'application/json'
  header 'Content-Type', 'application/json'

  let!(:user)       { users(:user_2) }
  let!(:user_token) { Doorkeeper::AccessToken.create!(resource_owner_id: user.id) }

  let!(:request) { requests(:request_1) }
  let!(:id)      { request.id }

  get '/api/v1/requests' do
    parameter :'page[number]',
              "The number of the desired page\n\n"\
              "If used, additional information is returned in the response headers:\n"\
              "`Pagination-Current-Page`: the current page number\n"\
              "`Pagination-Per`: the number of records per page\n"\
              "`Pagination-Total-Pages`: the total number of pages\n"\
              '`Pagination-Total-Count`: the total number of records',
              with_example: true,
              type: :integer,
              default: 1
    parameter :'page[size]',
              "The number of elements in a page\n\n"\
              "If used, additional information is returned in the response headers:\n"\
              "`Pagination-Current-Page`: the current page number\n"\
              "`Pagination-Per`: the number of records per page\n"\
              "`Pagination-Total-Pages`: the total number of pages\n"\
              '`Pagination-Total-Count`: the total number of records',
              with_example: true,
              type: :integer,
              default: FetcheableOnApi.configuration.pagination_default_size
    parameter :'filter[status]',
              'Filter requests by status using case insensitive exact matching',
              with_exemple: true

    example 'Get all requests' do
      authentication :basic, "Bearer #{user_token.token}"

      do_request

      expect(status).to eq(200)

      expect(response_body).to eq(Request.to_blueprint)
      expect(JSON.parse(response_body).count).to eq(Request.count)
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
    parameter :stage_name,
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

    let(:plant_stage_id) { Plant.last.plant_stages.last.id }
    let(:name)           { 'My request' }
    let(:due_date)       { Date.current + 6.months }
    let(:quantity)       { 150 }
    let(:comment)        { 'The specimens have to be in perfect condition, please be careful!' }
    let(:temperature)    { 35 }
    let(:photoperiod)    { 12 }

    let(:raw_post) { params.to_json }

    example 'Create a request' do
      authentication :basic, "Bearer #{user_token.token}"

      do_request

      expect(status).to eq(201)

      expect(response_body).to eq(Request.last.to_blueprint)

      response = JSON.parse(response_body)
      expect(response.dig('plant_stage_id')).to eq(plant_stage_id)
      expect(response.dig('name')).to eq(name)
      expect(response.dig('due_date')).to eq(due_date.strftime('%F'))
      expect(response.dig('quantity')).to eq(quantity)
      expect(response.dig('comment')).to eq(comment)
      expect(response.dig('temperature')).to eq(temperature)
      expect(response.dig('photoperiod')).to eq(photoperiod)
    end
  end

  put '/api/v1/requests/:id' do
    parameter :plant_stage_id, 'ID of the requested plant_stage', with_example: true
    parameter :name, 'Name of the request', with_example: true
    parameter :plant_name,
              'Name of the requested plant (ignored if plant_stage_id given)',
              with_example: true
    parameter :stage_name,
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

    let(:name)           { 'My updated request' }
    let(:due_date)       { Date.current + 6.months }
    let(:quantity)       { 150 }
    let(:comment)        { 'After all, this is less urgent, but I need more specimens!' }

    let(:raw_post) { params.to_json }

    example 'Update a request' do
      authentication :basic, "Bearer #{user_token.token}"

      do_request

      expect(status).to eq(200)

      request.reload
      expect(response_body).to eq(request.to_blueprint)
      expect(request.name).to eq(name)
      expect(request.due_date).to eq(due_date)
      expect(request.quantity).to eq(request.quantity)
      expect(request.comment).to eq(request.comment)
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
    end
  end

  post '/api/v1/requests/:id/cancel' do
    before do
      request.update(status: :pending)
    end

    example "Cancel a request\n"\
            'If the request is already accepted and the current user is a requester, '\
            'the request will be set as `in_cancelation`' do
      authentication :basic, "Bearer #{user_token.token}"

      do_request

      expect(status).to eq(200)

      request.reload
      expect(response_body).to eq(request.to_blueprint)
      expect(request.status).to eq(:canceled)
    end
  end

  delete '/api/v1/requests/:id' do
    example 'Delete a request' do
      authentication :basic, "Bearer #{user_token.token}"

      do_request

      expect(status).to eq(204)

      expect { request.reload }.to raise_exception(ActiveRecord::RecordNotFound)
    end
  end
end
