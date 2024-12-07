# frozen_string_literal: true

require 'acceptance_helper'

resource 'Benches' do
  explanation 'Benches resource'

  header 'Accept', 'application/json'
  header 'Content-Type', 'application/json'

  let!(:user) { users(:user2) }
  let!(:user_token) { Doorkeeper::AccessToken.create!(resource_owner_id: user.id) }

  let!(:greenhouse) { greenhouses(:greenhouse1) }
  let!(:greenhouse_id) { greenhouse.id }
  let!(:bench) { greenhouse.benches.first }
  let!(:id) { bench.id }

  get '/api/v1/greenhouses/:greenhouse_id/benches' do
    parameter :'page[number]', "The number of the desired page\n\n" \
                               "If used, additional information is returned in the response headers:\n" \
                               "`Pagination-Current-Page`: the current page number\n" \
                               "`Pagination-Per`: the number of records per page\n" \
                               "`Pagination-Total-Pages`: the total number of pages\n" \
                               '`Pagination-Total-Count`: the total number of records',
              with_example: true,
              type: :integer,
              default: 1
    parameter :'page[size]', "The number of elements in a page\n\n" \
                             "If used, additional information is returned in the response headers:\n" \
                             "`Pagination-Current-Page`: the current page number\n" \
                             "`Pagination-Per`: the number of records per page\n" \
                             "`Pagination-Total-Pages`: the total number of pages\n" \
                             '`Pagination-Total-Count`: the total number of records',
              with_example: true,
              type: :integer,
              default: FetcheableOnApi.configuration.pagination_default_size

    example 'Get all benches in the given greenhouse' do
      authentication :basic, "Bearer #{user_token.token}"

      do_request

      expect(status).to eq(200)

      expect(response_body).to eq(greenhouse.benches.to_blueprint)
      expect(JSON.parse(response_body).count).to eq(greenhouse.benches.count)
    end
  end

  get '/api/v1/benches/:id' do
    example 'Get a bench' do
      authentication :basic, "Bearer #{user_token.token}"

      do_request

      expect(status).to eq(200)
      expect(response_body).to eq(bench.to_blueprint)
    end
  end

  post '/api/v1/greenhouses/:greenhouse_id/benches' do
    parameter :name, '(Optional) Name of the bench', with_example: true
    parameter :dimensions, '(Optional) Dimensions of the bench (in centimeters)', with_example: true, type: :array,
              items: { type: :integer }
    parameter :positions, '(Optional) Position of the bench (in pixel)', with_example: true, type: :array,
              items: { type: :integer }

    let(:name) { 'my rectangular bench' }
    let(:dimensions) { [100, 200] }
    let(:positions) { [900, 20] }
    let(:raw_post) { params.to_json }

    example 'Create a bench with its area in the given greenhouse' do
      authentication :basic, "Bearer #{user_token.token}"

      do_request

      expect(status).to eq(201)

      expect(response_body).to eq(Bench.last.to_blueprint)

      response = JSON.parse(response_body)
      expect(response['name']).not_to be_blank
      expect(response['dimensions']).not_to be_blank
      expect(response['positions']).not_to be_blank
      expect(response['name']).to eq(name)
      expect(response['dimensions']).to eq(dimensions)
      expect(response['positions']).to eq(positions)
    end
  end

  put '/api/v1/benches/:id' do
    parameter :name, 'Name of the bench', with_example: true
    parameter :dimensions, '(Optional) Dimensions of the bench (in centimeters)', with_example: true, type: :array,
              items: { type: :integer }
    parameter :positions, '(Optional) Position of the bench (in pixel)', with_example: true, type: :array,
              items: { type: :integer }

    let(:name) { 'my square bench' }
    let(:dimensions) { [100, 300] }
    let(:positions) { [100, 800] }
    let(:raw_post) { params.to_json }

    example 'Update a bench' do
      authentication :basic, "Bearer #{user_token.token}"

      do_request

      expect(status).to eq(200)

      bench.reload
      expect(response_body).to eq(bench.to_blueprint)
      expect(bench.name).to eq(name)
      expect(bench.dimensions).to eq(dimensions)
      expect(bench.positions).to eq(positions)
    end
  end

  delete '/api/v1/benches/:id' do
    before do
      bench.request_distributions.destroy_all
    end

    example 'Delete a bench' do
      authentication :basic, "Bearer #{user_token.token}"

      do_request

      expect(status).to eq(204)

      expect { bench.reload }.to raise_exception(ActiveRecord::RecordNotFound)
    end
  end
end
