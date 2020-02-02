# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api/V1/Greenhouses', type: :request do
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

  let!(:greenhouse) { greenhouses(:greenhouse_1) }
  let!(:id)         { greenhouse.id }

  describe 'GET api/v1/greenhouses' do
    context 'when 200' do
      it 'get greenhouses with pagination params' do
        get(
          '/api/v1/greenhouses',
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
        expect(response.headers.dig('Pagination-Total-Pages')).to eq(1)
        expect(response.headers.dig('Pagination-Total-Count')).to eq(2)
      end
    end

    context 'when 403' do
      it 'can\'t get greenhouses as a requester' do
        get('/api/v1/greenhouses', headers: requester_header)

        expect(status).to eq(403)
        expect(JSON.parse(response.body).dig('error', 'message')).not_to be_blank
      end
    end
  end

  describe 'GET api/v1/greenhouses/:id' do
    context 'when 404' do
      it 'can\'t get a greenhouse as a requester' do
        get("/api/v1/greenhouses/#{id}", headers: requester_header)

        expect(status).to eq(404)
        expect(JSON.parse(response.body).dig('error', 'message')).not_to be_blank
      end
    end
  end

  describe 'POST api/v1/greenhouses' do
    context 'when 403' do
      it 'can\'t create a greenhouse as a requester' do
        post('/api/v1/greenhouses', headers: requester_header)

        expect(status).to eq(403)
        expect(JSON.parse(response.body).dig('error', 'message')).not_to be_blank
      end
    end

    context 'when 422' do
      it 'fails to create a greenhouse with invalid params' do
        post(
          '/api/v1/greenhouses',
          headers: header,
          params: {
            name: 'foobar',
            width: 100,
            height: -1
          }
        )

        expect(status).to eq(422)
        expect(JSON.parse(response.body).dig('error', 'message')).not_to be_blank
      end
    end
  end

  describe 'PUT api/v1/greenhouses/:id' do
    context 'when 404' do
      it 'can\'t udpdate a greenhouse as a requester' do
        put("/api/v1/greenhouses/#{id}", headers: requester_header)

        expect(status).to eq(404)
        expect(JSON.parse(response.body).dig('error', 'message')).not_to be_blank
      end
    end

    context 'when 422' do
      it 'fails to update a greenhouse with invalid params' do
        put(
          "/api/v1/greenhouses/#{id}",
          headers: header,
          params: {
            name: 'foobar',
            width: -1,
            height: 100
          }
        )

        expect(status).to eq(422)
        expect(JSON.parse(response.body).dig('error', 'message')).not_to be_blank
      end
    end
  end

  describe 'DELETE api/v1/greenhouses/:id' do
    context 'when 404' do
      it 'can\'t delete a greenhouse as a requester' do
        delete("/api/v1/greenhouses/#{id}", headers: requester_header)

        expect(status).to eq(404)
        expect(JSON.parse(response.body).dig('error', 'message')).not_to be_blank
      end
    end

    context 'when 422' do
      it 'fails to delete a greenhouse' do
        allow_any_instance_of(Greenhouse).to receive(:destroy).and_return(false)

        delete("/api/v1/greenhouses/#{id}", headers: header)

        expect(status).to eq(422)
        expect(JSON.parse(response.body).dig('error', 'message')).not_to be_blank
      end
    end
  end
end
