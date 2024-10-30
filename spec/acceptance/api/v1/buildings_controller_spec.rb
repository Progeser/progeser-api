# frozen_string_literal: true

require 'acceptance_helper'

resource 'Buildings' do
  explanation 'Buildings resource'

  header 'Accept',       'application/json'
  header 'Content-Type', 'application/json'

  let!(:user)       { users(:user2) }
  let!(:user_token) { Doorkeeper::AccessToken.create!(resource_owner_id: user.id) }

  let!(:building) { buildings(:building1) }
  let!(:id)       { building.id }

  get '/api/v1/buildings' do
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

    example 'Get all buildings' do
      authentication :basic, "Bearer #{user_token.token}"

      do_request

      expect(status).to eq(200)
      expect(response_body).to eq(Building.to_blueprint)
      expect(JSON.parse(response_body).count).to eq(Building.count)
    end
  end

  get '/api/v1/buildings/:id' do
    example 'Get a building' do
      authentication :basic, "Bearer #{user_token.token}"

      do_request

      expect(status).to eq(200)
      expect(response_body).to eq(building.to_blueprint)
    end
  end

  post '/api/v1/buildings' do
    parameter :name, 'Name of the building', with_example: true
    parameter :description, 'Description of the building', with_example: true

    let(:name)        { 'New Building' }
    let(:description) { 'A new description for the building' }

    let(:raw_post) { params.to_json }

    example 'Create a building' do
      authentication :basic, "Bearer #{user_token.token}"

      do_request

      expect(status).to eq(201)
      expect(response_body).to eq(Building.last.to_blueprint)

      response = JSON.parse(response_body)
      expect(response['name']).to eq(name)
      expect(response['description']).to eq(description)
    end
  end

  put '/api/v1/buildings/:id' do
    parameter :name, 'Updated name of the building', with_example: true
    parameter :description, 'Updated description of the building', with_example: true

    let(:name)        { 'Updated Building Name' }
    let(:description) { 'Updated building description' }

    let(:raw_post) { params.to_json }

    example 'Update a building' do
      authentication :basic, "Bearer #{user_token.token}"

      do_request

      expect(status).to eq(200)

      building.reload
      expect(response_body).to eq(building.to_blueprint)
      expect(building.name).to eq(name)
      expect(building.description).to eq(description)
    end
  end

  delete '/api/v1/buildings/:id' do
    let!(:building_without_requests) { Building.create!(name: 'Test Building', description: 'A building without requests') }

    before do
      # Création d'un bâtiment et d'une serre sans `request_distributions`
      greenhouse = building_without_requests.greenhouses.create!(name: 'Test Greenhouse', width: 10, height: 10)

      bench = greenhouse.benches.create!(
        name: 'Valid Bench',
        shape: 'circle',
        area: 10.0
      )
    end

    example 'Delete a building without associated requests' do
      authentication :basic, "Bearer #{user_token.token}"
      do_request(id: building_without_requests.id)

      expect(status).to eq(204)
      expect(Building.find_by(id: building_without_requests.id)).to be_nil
    end
  end
end
