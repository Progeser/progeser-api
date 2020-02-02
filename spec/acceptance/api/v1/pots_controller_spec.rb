# frozen_string_literal: true

require 'acceptance_helper'

resource 'Pots' do
  explanation 'Pots resource'

  header 'Accept',       'application/json'
  header 'Content-Type', 'application/json'

  let!(:user)       { users(:user_2) }
  let!(:user_token) { Doorkeeper::AccessToken.create!(resource_owner_id: user.id) }

  let!(:pot) { pots(:pot_1) }
  let!(:id)  { pot.id }

  get '/api/v1/pots' do
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

    example 'Get all pots' do
      authentication :basic, "Bearer #{user_token.token}"

      do_request

      expect(status).to eq(200)

      expect(response_body).to eq(Pot.to_blueprint)
      expect(JSON.parse(response_body).count).to eq(Pot.count)
    end
  end

  get '/api/v1/pots/:id' do
    example 'Get a pot' do
      authentication :basic, "Bearer #{user_token.token}"

      do_request

      expect(status).to eq(200)
      expect(response_body).to eq(pot.to_blueprint)
    end
  end

  post '/api/v1/pots' do
    parameter :name, 'Name of the pot', with_example: true
    parameter :shape,
              "Shape of the pot\n\n"\
              'If `other` given, `area` param should be passed',
              with_example: true,
              enum: Pot.shape.values
    parameter :area,
              "(Optional) Area of the pot (in square centimeters)\n\n"\
              'If used, following `dimensions` parameter will be ignored',
              with_example: true,
              type: :number
    parameter :dimensions,
              '(Optional) Dimensions of the pot (in centimeters)',
              with_example: true,
              type: :array,
              items: { type: :integer }

    let(:name)       { 'my rectangular pot' }
    let(:shape)      { 'rectangle' }
    let(:dimensions) { [10, 20] }

    let(:raw_post) { params.to_json }

    example 'Create a pot with its area' do
      authentication :basic, "Bearer #{user_token.token}"

      do_request

      expect(status).to eq(201)

      expect(response_body).to eq(Pot.last.to_blueprint)

      response = JSON.parse(response_body)
      expect(response.dig('name')).to eq(name)
      expect(response.dig('shape', 'name')).not_to be_blank
      expect(response.dig('shape', 'dimension_names')).not_to be_blank
      expect(response.dig('dimensions')).to eq(dimensions)
      expect(response.dig('area')).to eq(dimensions.inject(:*).to_f)
    end
  end

  put '/api/v1/pots/:id' do
    parameter :name, 'Name of the pot', with_example: true
    parameter :shape,
              "Shape of the pot\n\n"\
              'If `other` given, `area` param should be passed',
              with_example: true,
              enum: Pot.shape.values
    parameter :area,
              "(Optional) Area of the pot (in square centimeters)\n\n"\
              'If used, following `dimensions` parameter will be ignored',
              with_example: true,
              type: :number
    parameter :dimensions,
              '(Optional) Dimensions of the pot (in centimeters)',
              with_example: true,
              type: :array,
              items: { type: :integer }

    let(:name)       { 'my square pot' }
    let(:shape)      { 'square' }
    let(:dimensions) { [8] }

    let(:raw_post) { params.to_json }

    example 'Update a pot with its area' do
      authentication :basic, "Bearer #{user_token.token}"

      do_request

      expect(status).to eq(200)

      pot.reload
      expect(response_body).to eq(pot.to_blueprint)
      expect(pot.name).to eq(name)
      expect(pot.shape).to eq(shape)
      expect(pot.area).to eq(64.0)
    end
  end

  delete '/api/v1/pots/:id' do
    example 'Delete a pot' do
      authentication :basic, "Bearer #{user_token.token}"

      do_request

      expect(status).to eq(204)

      expect { pot.reload }.to raise_exception(ActiveRecord::RecordNotFound)
    end
  end
end
