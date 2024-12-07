# frozen_string_literal: true

require 'acceptance_helper'

resource 'Plants' do
  explanation 'Plants resource'

  header 'Accept', 'application/json'
  header 'Content-Type', 'application/json'

  let!(:user) { users(:user2) }
  let!(:user_token) { Doorkeeper::AccessToken.create!(resource_owner_id: user.id) }

  let!(:plant) { plants(:plant1) }
  let!(:id) { plant.id }

  get '/api/v1/plants' do
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

    example 'Get all plants with their stages' do
      authentication :basic, "Bearer #{user_token.token}"

      do_request

      expect(status).to eq(200)

      expect(response_body).to eq(Plant.to_blueprint)
      expect(JSON.parse(response_body).count).to eq(Plant.count)
      expect(JSON.parse(response_body).first['plant_stages']).not_to be_blank
    end
  end

  get '/api/v1/plants/:id' do
    example 'Get a plant with its stages' do
      authentication :basic, "Bearer #{user_token.token}"

      do_request

      expect(status).to eq(200)
      expect(response_body).to eq(plant.to_blueprint)
      expect(JSON.parse(response_body)['plant_stages']).not_to be_blank
    end
  end

  post '/api/v1/plants' do
    parameter :name, 'Name of the plant', with_example: true
    parameter :plant_stages_attributes,
              "Plant stages attributes\n" \
              'A plant stage should have a name, a duration and a position',
              with_example: true,
              type: :array,
              items: { type: :object }

    let(:name) { Faker::Food.vegetables }
    let(:plant_stages_attributes) do
      [
        { name: 'sprout', duration: Faker::Number.between(from: 5, to: 30), position: 1 },
        { name: 'seedling', duration: Faker::Number.between(from: 5, to: 30), position: 2 }
      ]
    end

    let(:raw_post) { params.to_json }

    example 'Create a plant' do
      authentication :basic, "Bearer #{user_token.token}"

      do_request

      expect(status).to eq(201)

      expect(response_body).to eq(Plant.last.to_blueprint)

      response = JSON.parse(response_body)
      expect(response['name']).to eq(name)
      expect(response['plant_stages'].count).to eq(2)
    end
  end

  put '/api/v1/plants/:id' do
    parameter :name, 'Name of the plant', with_example: true
    parameter :plant_stages_attributes,
              "Plant stages attributes\n" \
              "A plant stage should have a name, a duration and a position\n" \
              "To update attributes of an existing stage, its `id` should be passed\n" \
              'To update the `position` of a specific stage, you can simply pass it alone; ' \
              "other positions will be automatically scaled\n" \
              'To destroy an existing stage, `_destroy` param should be set to true',
              with_example: true,
              type: :array,
              items: { type: :object }

    let(:name) { 'Updated name' }
    let(:plant_stages_attributes) do
      [
        { id: 1, _destroy: true },
        { id: 2, _destroy: true },
        { id: 3, name: 'stage 3', duration: 10 },
        { id: 6, position: 1 }
      ]
    end

    let(:raw_post) { params.to_json }

    example 'Update a plant' do
      authentication :basic, "Bearer #{user_token.token}"

      do_request

      expect(status).to eq(200)

      plant.reload
      expect(response_body).to eq(plant.to_blueprint)
      expect(plant.name).to eq(name)

      # 2 stages have been destroyed
      expect(plant.plant_stages.count).to eq(4)

      # plant stage 3 has been updated
      expect(PlantStage.find(3).name).to eq('stage 3')
      expect(PlantStage.find(3).duration).to eq(10)

      # positions have been scaled
      expect(plant.plant_stages.first.id).to eq(6)
      expect(plant.plant_stages.last.id).to eq(5)
      expect(plant.plant_stages.last.position).to eq(4)
    end
  end

  delete '/api/v1/plants/:id' do
    before do
      plant.plant_stages.flat_map(&:requests).map(&:destroy)
      plant.plant_stages.flat_map(&:request_distributions).map(&:destroy)
    end

    example 'Delete a plant' do
      authentication :basic, "Bearer #{user_token.token}"

      do_request

      expect(status).to eq(204)

      expect { plant.reload }.to raise_exception(ActiveRecord::RecordNotFound)
    end
  end
end
