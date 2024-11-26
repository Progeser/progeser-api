# frozen_string_literal: true

require 'acceptance_helper'

resource 'RequestDistributions' do
  explanation 'RequestDistributions resource'

  header 'Accept', 'application/json'
  header 'Content-Type', 'application/json'

  let!(:user) { users(:user2) }
  let!(:user_token) { Doorkeeper::AccessToken.create!(resource_owner_id: user.id) }

  let!(:request) { requests(:request1) }
  let!(:request_id) { request.id }
  let!(:distribution) { request.request_distributions.first }
  let!(:id) { distribution.id }

  get '/api/v1/requests/:request_id/request_distributions' do
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
    parameter :plant_stage_id, 'ID of the plant_stage of the experiment', with_example: true

    let(:plant_stage_id) { request.plant_stage.plant.plant_stages.first.id }
    let(:raw_post) { params.to_json }

    example 'Create a distribution for the given request' do
      authentication :basic, "Bearer #{user_token.token}"

      do_request

      expect(status).to eq(201)

      expect(response_body).to eq(RequestDistribution.last.to_blueprint)

      response = JSON.parse(response_body)
      expect(response['plant_stage_id']).to eq(plant_stage_id)
    end
  end

  put '/api/v1/request_distributions/:id' do
    parameter :plant_stage_id, 'ID of the plant_stage of the experiment', with_example: true

    let(:plant_stage_id) { request.plant_stage.plant.plant_stages.second.id }
    let(:raw_post) { params.to_json }

    example 'Update a request distribution' do
      authentication :basic, "Bearer #{user_token.token}"

      do_request

      expect(status).to eq(200)

      distribution.reload
      expect(response_body).to eq(distribution.to_blueprint)
      expect(distribution.plant_stage_id).to eq(plant_stage_id)
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
