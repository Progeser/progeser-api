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

  let!(:pot) { pots(:pot_1) }
  let!(:id)  { pot.id }

  describe 'GET api/v1/pots' do
    context '200' do
      it 'get pots with pagination params' do
        get(
          '/api/v1/pots',
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
        expect(response.headers.dig('Pagination-Total-Pages')).to eq(3)
        expect(response.headers.dig('Pagination-Total-Count')).to eq(5)
      end
    end

    context '403' do
      it 'can\'t get pots as a requester' do
        get('/api/v1/pots', headers: requester_header)

        expect(status).to eq(403)
        expect(JSON.parse(response.body).dig('error', 'message')).not_to be_blank
      end
    end
  end

  describe 'GET api/v1/pots/:id' do
    context '404' do
      it 'can\'t get a pot as a requester' do
        get("/api/v1/pots/#{id}", headers: requester_header)

        expect(status).to eq(404)
        expect(JSON.parse(response.body).dig('error', 'message')).not_to be_blank
      end
    end
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
        expect(pot.dimensions).to eq([12])
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
        expect(pot.dimensions).to eq(nil)
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
        expect(pot.dimensions).to eq([4, 8])
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
        expect(pot.dimensions).to eq(nil)
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
        expect(pot.dimensions).to eq([10])
        expect(pot.area).to eq(31.4159265358979)
        expect(response.parsed_body.dig('area')).to eq(31.42)
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
        expect(pot.dimensions).to eq(nil)
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
        expect(pot.dimensions).to eq([7, 5])
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
        expect(pot.dimensions).to eq(nil)
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
        expect(pot.dimensions).to eq(nil)
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

  describe 'PUT api/v1/pots/:id' do
    context '404' do
      it 'can\'t update a pot as a requester' do
        put("/api/v1/pots/#{id}", headers: requester_header)

        expect(status).to eq(404)
        expect(JSON.parse(response.body).dig('error', 'message')).not_to be_blank
      end
    end
  end

  describe 'DELETE api/v1/pots/:id' do
    context '404' do
      it 'can\'t delete a pot as a requester' do
        delete("/api/v1/pots/#{id}", headers: requester_header)

        expect(status).to eq(404)
        expect(JSON.parse(response.body).dig('error', 'message')).not_to be_blank
      end
    end

    context '422' do
      it 'fails to delete a pot' do
        allow_any_instance_of(Pot).to receive(:destroy).and_return(false)

        delete("/api/v1/pots/#{id}", headers: header)

        expect(status).to eq(422)
        expect(JSON.parse(response.body).dig('error', 'message')).not_to be_blank
      end
    end
  end
end
