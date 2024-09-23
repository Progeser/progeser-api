# frozen_string_literal: true

require 'acceptance_helper'

resource 'Greenhouses' do
  explanation 'Greenhouses resource'

  header 'Accept',       'application/json'
  header 'Content-Type', 'application/json'

  let!(:user)       { users(:user2) }
  let!(:user_token) { Doorkeeper::AccessToken.create!(resource_owner_id: user.id) }

  let!(:greenhouse) { greenhouses(:greenhouse1) }
  let!(:id)         { greenhouse.id }

  get '/api/v1/greenhouses' do
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

    example 'Get all greenhouses' do
      authentication :basic, "Bearer #{user_token.token}"

      do_request

      expect(status).to eq(200)

      expect(response_body).to eq(Greenhouse.to_blueprint)
      expect(JSON.parse(response_body).count).to eq(Greenhouse.count)
    end
  end

  get '/api/v1/greenhouses/:id' do
    example 'Get a greenhouse' do
      authentication :basic, "Bearer #{user_token.token}"

      do_request

      expect(status).to eq(200)
      expect(response_body).to eq(greenhouse.to_blueprint)
    end
  end

  post '/api/v1/greenhouses' do
    parameter :name, 'Name of the greenhouse', with_example: true
    parameter :width, 'Width of the greenhouse', with_example: true, type: :integer
    parameter :height, 'Height of the greenhouse', with_example: true, type: :integer

    let(:name)   { 'My new greenhouse' }
    let(:width)  { 100 }
    let(:height) { 200 }

    let(:raw_post) { params.to_json }

    example 'Create a greenhouse' do
      authentication :basic, "Bearer #{user_token.token}"

      do_request

      expect(status).to eq(201)

      expect(response_body).to eq(Greenhouse.last.to_blueprint)

      response = JSON.parse(response_body)
      expect(response['name']).to eq(name)
      expect(response['width']).to eq(width)
      expect(response['height']).to eq(height)
      expect(response['occupancy']).to eq('0.0')
    end
  end

  put '/api/v1/greenhouses/:id' do
    parameter :name, 'The new name of the greenhouse', with_example: true
    parameter :width, 'The new width of the greenhouse', with_example: true, type: :integer
    parameter :height, 'The new height of the greenhouse', with_example: true, type: :integer

    let(:name)   { 'Updated name' }
    let(:width)  { 100 }
    let(:height) { 200 }

    let(:raw_post) { params.to_json }

    example 'Update a greenhouse' do
      authentication :basic, "Bearer #{user_token.token}"

      do_request

      expect(status).to eq(200)

      greenhouse.reload
      expect(response_body).to eq(greenhouse.to_blueprint)
      expect(greenhouse.name).to eq(name)
      expect(greenhouse.width).to eq(width)
      expect(greenhouse.height).to eq(height)
      expect(greenhouse.occupancy).to eq(greenhouse.compute_occupancy)
    end
  end

  delete '/api/v1/greenhouses/:id' do
    before do
      greenhouse.benches.flat_map(&:request_distributions).map(&:destroy)
    end

    example 'Delete a greenhouse' do
      authentication :basic, "Bearer #{user_token.token}"

      do_request

      expect(status).to eq(204)

      expect { greenhouse.reload }.to raise_exception(ActiveRecord::RecordNotFound)
    end
  end
end
