# frozen_string_literal: true

require 'acceptance_helper'

resource 'Distributions' do
  explanation 'Distributions resource'

  header 'Accept', 'application/json'
  header 'Content-Type', 'application/json'

  let!(:user) { users(:user2) }
  let!(:user_token) { Doorkeeper::AccessToken.create!(resource_owner_id: user.id) }

  let!(:greenhouse) { greenhouses(:greenhouse1) }
  let!(:greenhouse_id) { greenhouse.id }

  let!(:distribution) { distributions(:distribution1) }
  let!(:distribution_id) { distribution.id }

  let!(:bench) { benches(:bench1) }
  let!(:pot) { pots(:pot1) }
  let!(:request_distribution) { request_distributions(:request_distribution1) }

  get '/api/v1/greenhouses/:greenhouse_id/distributions' do
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

    example 'Get all distributions in the given greenhouse' do
      authentication :basic, "Bearer #{user_token.token}"

      do_request

      expect(status).to eq(200)

      distributions = Distribution.joins(bench: :greenhouse).where(benches: { greenhouse_id: greenhouse.id })
      returned_distributions = JSON.parse(response_body)

      expect(returned_distributions.count).to eq(distributions.count)

      returned_distributions.each do |distribution_response|
        distribution = Distribution.find(distribution_response['id'])
        expect(distribution.bench.greenhouse_id).to eq(greenhouse.id)
      end
    end

    get '/api/v1/distributions/:distribution_id' do
      example 'Get a distribution' do
        authentication :basic, "Bearer #{user_token.token}"

        do_request

        expect(status).to eq(200)
        expect(response_body).to eq(distribution.to_blueprint)
      end
    end

    post '/api/v1/distributions' do
      parameter :request_distribution_id, 'Request Distribution ID', with_example: true
      parameter :bench_id, 'Bench ID', with_example: true
      parameter :pot_id, 'Pot ID', with_example: true
      parameter :positions_on_bench, 'Positions on Bench', with_example: true, type: :array, items: { type: :object }
      parameter :dimensions, 'Dimensions', with_example: true, type: :array, items: { type: :object }
      parameter :seed_quantity, 'Seed Quantity', with_example: true

      let(:request_distribution_id) { request_distribution.id }
      let(:bench_id) { bench.id }
      let(:pot_id) { pot.id }
      let(:positions_on_bench) do
        [150, 50]
      end
      let(:dimensions) do
        [10, 10]
      end
      let(:seed_quantity) { 10 }

      let(:raw_post) { params.to_json }

      example 'Create a distribution' do
        authentication :basic, "Bearer #{user_token.token}"

        do_request

        expect(status).to eq(201)

        response = JSON.parse(response_body)
        expect(response['request_distribution_id']).to eq(request_distribution_id)
        expect(response['bench_id']).to eq(bench_id)
        expect(response['pot_id']).to eq(pot_id)
        expect(response['positions_on_bench']).to eq(positions_on_bench)
        expect(response['dimensions']).to eq(dimensions)
        expect(response['seed_quantity']).to eq(seed_quantity)
      end
    end

    put '/api/v1/distributions/:distribution_id' do
      parameter :positions_on_bench, 'Positions on Bench', with_example: true, type: :array, items: { type: :object }
      parameter :dimensions, 'Dimensions', with_example: true, type: :array, items: { type: :object }
      parameter :seed_quantity, 'Seed Quantity', with_example: true

      let(:positions_on_bench) do
        [180, 60]
      end
      let(:dimensions) do
        [15, 18]
      end
      let(:seed_quantity) { 12 }

      let(:raw_post) { params.to_json }

      example 'Update a distribution' do
        authentication :basic, "Bearer #{user_token.token}"

        do_request

        puts(response_body)

        expect(status).to eq(200)

        response = JSON.parse(response_body)
        expect(response['positions_on_bench']).to eq(positions_on_bench)
        expect(response['dimensions']).to eq(dimensions)
        expect(response['seed_quantity']).to eq(seed_quantity)
      end
    end
  end

  delete '/api/v1/distributions/:distribution_id' do
    example 'Delete a distribution' do
      authentication :basic, "Bearer #{user_token.token}"

      do_request

      expect(status).to eq(204)

      expect { distribution.reload }.to raise_exception(ActiveRecord::RecordNotFound)
    end
  end
end
