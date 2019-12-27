# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api/V1/Shapes', type: :request do
  let!(:user)  { users(:user_2) }
  let!(:token) { Doorkeeper::AccessToken.create!(resource_owner_id: user.id) }
  let!(:header) do
    { 'Authorization': "Bearer #{token.token}" }
  end

  let!(:requester)       { users(:user_1) }
  let!(:requester_token) { Doorkeeper::AccessToken.create!(resource_owner_id: requester.id) }
  let!(:requester_header) do
    { 'Authorization': "Bearer #{requester_token.token}" }
  end

  describe 'GET api/v1/shapes' do
    context '200' do
      it 'get shapes with valid attributes' do
        get('/api/v1/shapes', headers: header)

        expect(status).to eq(200)

        JSON.parse(response.body).each do |shape|
          name = shape.dig('name')
          klass = "Shape::#{name.capitalize}".constantize

          expect(Pot::SHAPE_KINDS.include?(name)).to eq(true)
          expect(shape.dig('dimension_names')).to eq(klass::DIMENSIONS_NAMES)
        end
      end
    end

    context '403' do
      it 'can\'t get shapes as a requester' do
        get('/api/v1/shapes', headers: requester_header)

        expect(status).to eq(403)
        expect(JSON.parse(response.body).dig('error', 'message')).not_to be_blank
      end
    end
  end
end
