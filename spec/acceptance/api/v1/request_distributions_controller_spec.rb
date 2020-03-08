# frozen_string_literal: true

require 'acceptance_helper'

resource 'RequestDistributions' do
  explanation 'RequestDistributions resource'

  header 'Accept',       'application/json'
  header 'Content-Type', 'application/json'

  let!(:user)       { users(:user_2) }
  let!(:user_token) { Doorkeeper::AccessToken.create!(resource_owner_id: user.id) }

  let!(:request)      { requests(:request_1) }
  let!(:request_id)   { request.id }
  let!(:distribution) { request.request_distributions.first }
  let!(:id)           { distribution.id }

  get '/api/v1/requests/:request_id/request_distributions' do
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

    example 'Get all distributions of the given request' do
      authentication :basic, "Bearer #{user_token.token}"

      do_request

      expect(status).to eq(200)

      expect(response_body).to eq(request.request_distributions.to_blueprint)
      expect(JSON.parse(response_body).count).to eq(request.request_distributions.count)
    end
  end

  get '/api/v1/request_distributions/:id' do
    example 'Get a request distribution' do
      authentication :basic, "Bearer #{user_token.token}"

      do_request

      expect(status).to eq(200)
      expect(response_body).to eq(distribution.to_blueprint)
    end
  end

  post '/api/v1/requests/:request_id/request_distributions' do
    parameter :bench_id, 'ID of the bench where the specimens are placed', with_example: true
    parameter :plant_stage_id, 'ID of the plant_stage of the experiment', with_example: true
    parameter :pot_id,
              "(Optional) ID of the pot used for the experiment\n"\
              'If used, following param `pot_quantity` is required',
              with_example: true
    parameter :pot_quantity,
              "(Optional) Number of pots used for the experiment\n"\
              'If used, previous param `pot_id` is required',
              with_example: true,
              type: :integer
    parameter :area,
              "(Optional) Total area of the experiment\n"\
              'If used, previous params `pot_id` and `pot_quantity` will be ignored',
              with_example: true,
              type: :number

    let(:bench_id) { Bench.first.id }
    let(:plant_stage_id) { request.plant_stage.plant.plant_stages.first.id }
    let(:pot_id) { Pot.first.id }
    let(:pot_quantity) { 30 }

    let(:raw_post) { params.to_json }

    example 'Create a distribution for the given request' do
      authentication :basic, "Bearer #{user_token.token}"

      do_request

      expect(status).to eq(201)

      expect(response_body).to eq(RequestDistribution.last.to_blueprint)

      response = JSON.parse(response_body)
      expect(response.dig('bench_id')).to eq(bench_id)
      expect(response.dig('greenhouse_id')).to eq(Bench.first.greenhouse_id)
      expect(response.dig('plant_stage_id')).to eq(plant_stage_id)
      expect(response.dig('pot_id')).to eq(pot_id)
      expect(response.dig('pot_quantity')).to eq(pot_quantity)
      expect(response.dig('area')).not_to be_blank
    end
  end

  put '/api/v1/request_distributions/:id' do
    parameter :bench_id, 'ID of the bench where the specimens are placed', with_example: true
    parameter :plant_stage_id, 'ID of the plant_stage of the experiment', with_example: true
    parameter :pot_id,
              "(Optional) ID of the pot used for the experiment\n"\
              'If used, following param `pot_quantity` is required',
              with_example: true
    parameter :pot_quantity,
              "(Optional) Number of pots used for the experiment\n"\
              'If used, previous param `pot_id` is required',
              with_example: true,
              type: :integer
    parameter :area,
              "(Optional) Total area of the experiment\n"\
              'If used, previous params `pot_id` and `pot_quantity` will be ignored',
              with_example: true,
              type: :number

    let(:bench_id) { Bench.last.id }
    let(:plant_stage_id) { request.plant_stage.plant.plant_stages.second.id }
    let(:pot_id) { Pot.second.id }
    let(:pot_quantity) { 20 }

    let(:raw_post) { params.to_json }

    example 'Update a request distribution' do
      authentication :basic, "Bearer #{user_token.token}"

      do_request

      expect(status).to eq(200)

      distribution.reload
      expect(response_body).to eq(distribution.to_blueprint)
      expect(distribution.bench_id).to eq(bench_id)
      expect(distribution.plant_stage_id).to eq(plant_stage_id)
      expect(distribution.pot_id).to eq(pot_id)
      expect(distribution.pot_quantity).to eq(pot_quantity)
      expect(distribution.area).not_to be_blank
    end
  end

  delete '/api/v1/request_distributions/:id' do
    example 'Delete a request distribution' do
      authentication :basic, "Bearer #{user_token.token}"

      do_request

      expect(status).to eq(204)

      expect { distribution.reload }.to raise_exception(ActiveRecord::RecordNotFound)
    end
  end
end
