# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api/V1/Pots', type: :request do
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

  describe 'POST api/v1/pots' do
    context '201' do
      it 'creates a square pot given its dimensions' do
        post(
          '/api/v1/pots',
          headers: header,
          params: {
            name: 'my square pot',
            shape: 'square',
            dimensions: [12]
          },
          as: :json
        )

        expect(status).to eq(201)

        pot = Pot.last
        expect(response.body).to eq(pot.to_blueprint)
        expect(pot.name).to eq('my square pot')
        expect(pot.shape).to eq('square')
        expect(pot.area).to eq(144.0)
      end

      it 'creates a square pot given its area' do
        post(
          '/api/v1/pots',
          headers: header,
          params: {
            name: 'my square pot',
            shape: 'square',
            area: 100.0
          },
          as: :json
        )

        expect(status).to eq(201)

        pot = Pot.last
        expect(response.body).to eq(pot.to_blueprint)
        expect(pot.name).to eq('my square pot')
        expect(pot.shape).to eq('square')
        expect(pot.area).to eq(100.0)
      end

      it 'creates a rectangular pot given its dimensions' do
        post(
          '/api/v1/pots',
          headers: header,
          params: {
            name: 'my rectangular pot',
            shape: 'rectangle',
            dimensions: [4, 8]
          },
          as: :json
        )

        expect(status).to eq(201)

        pot = Pot.last
        expect(response.body).to eq(pot.to_blueprint)
        expect(pot.name).to eq('my rectangular pot')
        expect(pot.shape).to eq('rectangle')
        expect(pot.area).to eq(32.0)
      end

      it 'creates a rectangular pot given its area' do
        post(
          '/api/v1/pots',
          headers: header,
          params: {
            name: 'my rectangular pot',
            shape: 'rectangle',
            area: 110.0
          },
          as: :json
        )

        expect(status).to eq(201)

        pot = Pot.last
        expect(response.body).to eq(pot.to_blueprint)
        expect(pot.name).to eq('my rectangular pot')
        expect(pot.shape).to eq('rectangle')
        expect(pot.area).to eq(110.0)
      end

      it 'creates a circular pot given its dimensions' do
        post(
          '/api/v1/pots',
          headers: header,
          params: {
            name: 'my circular pot',
            shape: 'circle',
            dimensions: [10]
          },
          as: :json
        )

        expect(status).to eq(201)

        pot = Pot.last
        expect(response.body).to eq(pot.to_blueprint)
        expect(pot.name).to eq('my circular pot')
        expect(pot.shape).to eq('circle')
        expect(pot.area).to eq(31.4159265358979)
      end

      it 'creates a circular pot given its area' do
        post(
          '/api/v1/pots',
          headers: header,
          params: {
            name: 'my circular pot',
            shape: 'circle',
            area: 120.0
          },
          as: :json
        )

        expect(status).to eq(201)

        pot = Pot.last
        expect(response.body).to eq(pot.to_blueprint)
        expect(pot.name).to eq('my circular pot')
        expect(pot.shape).to eq('circle')
        expect(pot.area).to eq(120.0)
      end

      it 'creates a triangular pot given its dimensions' do
        post(
          '/api/v1/pots',
          headers: header,
          params: {
            name: 'my triangular pot',
            shape: 'triangle',
            dimensions: [7, 5]
          },
          as: :json
        )

        expect(status).to eq(201)

        pot = Pot.last
        expect(response.body).to eq(pot.to_blueprint)
        expect(pot.name).to eq('my triangular pot')
        expect(pot.shape).to eq('triangle')
        expect(pot.area).to eq(17.5)
      end

      it 'creates a triangular pot given its area' do
        post(
          '/api/v1/pots',
          headers: header,
          params: {
            name: 'my triangular pot',
            shape: 'triangle',
            area: 130.0
          },
          as: :json
        )

        expect(status).to eq(201)

        pot = Pot.last
        expect(response.body).to eq(pot.to_blueprint)
        expect(pot.name).to eq('my triangular pot')
        expect(pot.shape).to eq('triangle')
        expect(pot.area).to eq(130.0)
      end

      it 'creates an other pot given its area' do
        post(
          '/api/v1/pots',
          headers: header,
          params: {
            name: 'my other pot',
            shape: 'other',
            area: 140.0
          },
          as: :json
        )

        expect(status).to eq(201)

        pot = Pot.last
        expect(response.body).to eq(pot.to_blueprint)
        expect(pot.name).to eq('my other pot')
        expect(pot.shape).to eq('other')
        expect(pot.area).to eq(140.0)
      end
    end

    context '403' do
      it 'can\'t create a pot as a requester' do
        post('/api/v1/pots', headers: requester_header)

        expect(status).to eq(403)
        expect(JSON.parse(response.body).dig('error', 'message')).not_to be_blank
      end
    end

    context '422' do
      context 'raises a Shape::InvalidKind' do
        it 'fails to create a pot with dimensions & invalid shape' do
          post(
            '/api/v1/pots',
            headers: header,
            params: {
              name: 'my foobar pot',
              shape: 'foobar',
              dimensions: [12]
            },
            as: :json
          )

          expect(status).to eq(422)
          expect(JSON.parse(response.body).dig('error', 'message')).not_to be_blank
        end

        it 'fails to create an other pot with no `area` given' do
          post(
            '/api/v1/pots',
            headers: header,
            params: {
              name: 'my other pot',
              shape: 'other',
              dimensions: [8]
            },
            as: :json
          )

          expect(status).to eq(422)
          expect(JSON.parse(response.body).dig('error', 'message')).not_to be_blank
        end
      end

      context 'raises a Shape::InvalidDimensionsNumber' do
        it 'fails to create a pot with invalid dimensions number' do
          post(
            '/api/v1/pots',
            headers: header,
            params: {
              name: 'my square pot',
              shape: 'square',
              dimensions: [4, 8]
            },
            as: :json
          )

          expect(status).to eq(422)
          expect(JSON.parse(response.body).dig('error', 'message')).not_to be_blank
        end
      end

      context 'raises an ActiveRecord::RecordInvalid' do
        it 'fails to create a pot with area & invalid shape' do
          post(
            '/api/v1/pots',
            headers: header,
            params: {
              name: 'my foobar pot',
              shape: 'foobar',
              area: 100.0
            },
            as: :json
          )

          expect(status).to eq(422)
          expect(JSON.parse(response.body).dig('error', 'message')).not_to be_blank
        end
      end
    end
  end
end
