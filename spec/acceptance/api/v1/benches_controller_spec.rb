# frozen_string_literal: true

require 'acceptance_helper'

resource 'Benches' do
  explanation 'Benches resource'

  header 'Accept',       'application/json'
  header 'Content-Type', 'application/json'

  let!(:user)       { users(:user_2) }
  let!(:user_token) { Doorkeeper::AccessToken.create!(resource_owner_id: user.id) }

  let!(:greenhouse)    { greenhouses(:greenhouse_1) }
  let!(:greenhouse_id) { greenhouse.id }
  let!(:bench)         { greenhouse.benches.first }
  let!(:id)            { bench.id }

  get '/api/v1/greenhouses/:greenhouse_id/benches' do
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
    parameter :name, '(Optional) Name of the bench',  with_example: true
    parameter :shape,
              "Shape of the bench\n\n"\
              'If `other` given, `area` param should be passed',
              with_example: true,
              enum: Bench.shape.values
    parameter :area,
              "(Optional) Area of the bench (in square centimeters)\n\n"\
              'If used, following `dimensions` parameter will be ignored',
              with_example: true,
              type: :number
    parameter :dimensions,
              '(Optional) Dimensions of the bench (in centimeters)',
              with_example: true,
              type: :array,
              items: { type: :integer }

    let(:name)       { 'my rectangular bench' }
    let(:shape)      { 'rectangle' }
    let(:dimensions) { [100, 200] }

    let(:raw_post) { params.to_json }

    example 'Create a bench with its area in the given greenhouse' do
      authentication :basic, "Bearer #{user_token.token}"

      do_request

      expect(status).to eq(201)

      expect(response_body).to eq(Bench.last.to_blueprint)

      response = JSON.parse(response_body)
      expect(response.dig('name')).to eq(name)
      expect(response.dig('shape', 'name')).not_to be_blank
      expect(response.dig('shape', 'dimension_names')).not_to be_blank
      expect(response.dig('dimensions')).to eq(dimensions)
      expect(response.dig('area')).to eq(dimensions.inject(:*).to_f)
    end
  end

  put '/api/v1/benches/:id' do
    parameter :name, 'Name of the bench',  with_example: true
    parameter :shape,
              "Shape of the bench\n\n"\
              'If `other` given, `area` param should be passed',
              with_example: true,
              enum: Bench.shape.values
    parameter :area,
              "(Optional) Area of the bench (in square centimeters)\n\n"\
              'If used, following `dimensions` parameter will be ignored',
              with_example: true,
              type: :number
    parameter :dimensions,
              '(Optional) Dimensions of the bench (in centimeters)',
              with_example: true,
              type: :array,
              items: { type: :integer }

    let(:name)       { 'my square bench' }
    let(:shape)      { 'square' }
    let(:dimensions) { [8] }

    let(:raw_post) { params.to_json }

    example 'Update a bench with its area' do
      authentication :basic, "Bearer #{user_token.token}"

      do_request

      expect(status).to eq(200)

      bench.reload
      expect(response_body).to eq(bench.to_blueprint)
      expect(bench.name).to eq(name)
      expect(bench.shape).to eq(shape)
      expect(bench.area).to eq(64.0)
    end
  end

  delete '/api/v1/benches/:id' do
    example 'Delete a bench' do
      authentication :basic, "Bearer #{user_token.token}"

      do_request

      expect(status).to eq(204)
      
      expect{bench.reload}.to raise_exception(ActiveRecord::RecordNotFound)
    end
  end
end
