# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api/V1/Plants', type: :request do
  let!(:user)   { users(:user_2) }
  let!(:token)  { Doorkeeper::AccessToken.create!(resource_owner_id: user.id) }
  let!(:header) do
    { 'Authorization': "Bearer #{token.token}" }
  end

  let!(:requester)       { users(:user_1) }
  let!(:requester_token) { Doorkeeper::AccessToken.create!(resource_owner_id: requester.id) }
  let!(:requester_header) do
    { 'Authorization': "Bearer #{requester_token.token}" }
  end

  let!(:plant) { plants(:plant_1) }
  let!(:id)         { plant.id }

  describe 'GET api/v1/plants' do
    context '200' do
      it 'get plants with pagination params' do
        get(
          '/api/v1/plants',
          headers: header,
          params: {
            page: {
              number: 1,
              size: 2
            }
          }
        )

        expect(status).to eq(200)

        expect(JSON.parse(response.body).count).to eq(2)
        expect(response.headers.dig('Pagination-Current-Page')).to eq(1)
        expect(response.headers.dig('Pagination-Per')).to eq(2)
        expect(response.headers.dig('Pagination-Total-Pages')).to eq(2)
        expect(response.headers.dig('Pagination-Total-Count')).to eq(3)
      end
    end
  end

  describe 'POST api/v1/plants' do
    context '403' do
      it 'can\'t create a plant as a requester' do
        post('/api/v1/plants', headers: requester_header)

        expect(status).to eq(403)
        expect(JSON.parse(response.body).dig('error', 'message')).not_to be_blank
      end
    end

    context '422' do
      # See comment on validation in app/models/plant.rb
      #
      # it 'fails to create a plant without plant_stage' do
      #   post(
      #     '/api/v1/plants',
      #     headers: header,
      #     params: {
      #       name: 'foobar'
      #     }
      #   )

      #   expect(status).to eq(422)
      #   expect(JSON.parse(response.body).dig('error', 'message')).not_to be_blank
      # end

      it 'fails to create a plant with missing params' do
        post(
          '/api/v1/plants',
          headers: header,
          params: {
            name: nil,
            plant_stages_attributes: nil
          }
        )

        expect(status).to eq(422)
        expect(JSON.parse(response.body).dig('error', 'message')).not_to be_blank
      end
    end
  end

  describe 'PUT api/v1/plants/:id' do
    context '403' do
      it 'can\'t udpdate a plant as a requester' do
        put("/api/v1/plants/#{id}", headers: requester_header)

        expect(status).to eq(403)
        expect(JSON.parse(response.body).dig('error', 'message')).not_to be_blank
      end
    end

    context '422' do
      # See comment on validation in app/models/plant.rb
      #
      # it 'fails to update a plant when trying to delete all its plant stages' do
      #   put(
      #     "/api/v1/plants/#{id}",
      #     headers: header,
      #     params: {
      #       name: 'foobar',
      #       plant_stages_attributes: plant.plant_stages.map { |ps| {id: ps.id, _destroy: true } }
      #     }
      #   )

      #   expect(status).to eq(422)
      #   expect(JSON.parse(response.body).dig('error', 'message')).not_to be_blank
      # end

      it 'fails to update a plant with missing params' do
        put(
          "/api/v1/plants/#{id}",
          headers: header,
          params: {
            name: nil
          }
        )

        expect(status).to eq(422)
        expect(JSON.parse(response.body).dig('error', 'message')).not_to be_blank
      end
    end
  end

  describe 'DELETE api/v1/plants/:id' do
    context '403' do
      it 'can\'t delete a plant as a requester' do
        delete("/api/v1/plants/#{id}", headers: requester_header)

        expect(status).to eq(403)
        expect(JSON.parse(response.body).dig('error', 'message')).not_to be_blank
      end
    end

    context '422' do
      it 'fails to delete a plant' do
        allow_any_instance_of(Plant).to receive(:destroy).and_return(false)

        delete("/api/v1/plants/#{id}", headers: header)

        expect(status).to eq(422)
        expect(JSON.parse(response.body).dig('error', 'message')).not_to be_blank
      end
    end
  end
end
