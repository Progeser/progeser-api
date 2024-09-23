# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api/V1/Pots', type: :request do
  let!(:pot) { pots(:pot1) }
  let!(:id)  { pot.id }

  describe 'GET api/v1/pots' do
    context 'when 200' do
      it_behaves_like 'with authenticated grower' do
        it 'get pots with pagination params' do
          get(
            '/api/v1/pots',
            headers:,
            params: {
              page: {
                number: 1,
                size: 2
              }
            }
          )

          expect(status).to eq(200)

          expect(response.parsed_body.count).to eq(2)
          expect(response.headers['Pagination-Current-Page']).to eq(1)
          expect(response.headers['Pagination-Per']).to eq(2)
          expect(response.headers['Pagination-Total-Pages']).to eq(3)
          expect(response.headers['Pagination-Total-Count']).to eq(5)
        end
      end
    end

    context 'when 403' do
      it_behaves_like 'with authenticated requester' do
        it 'can\'t get pots' do
          get('/api/v1/pots', headers:)

          expect(status).to eq(403)
          expect(response.parsed_body.dig('error', 'message')).not_to be_blank
        end
      end
    end
  end

  describe 'GET api/v1/pots/:id' do
    context 'when 404' do
      it_behaves_like 'with authenticated requester' do
        it 'can\'t get a pot' do
          get("/api/v1/pots/#{id}", headers:)

          expect(status).to eq(404)
          expect(response.parsed_body.dig('error', 'message')).not_to be_blank
        end
      end
    end
  end

  describe 'POST api/v1/pots' do
    context 'when 201' do
      it_behaves_like 'with authenticated grower' do
        it 'creates a square pot given its dimensions' do
          post(
            '/api/v1/pots',
            headers:,
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
            headers:,
            params: {
              name: 'my square pot',
              shape: 'square',
              area: '100.0'
            },
            as: :json
          )

          expect(status).to eq(201)

          pot = Pot.last
          expect(response.body).to eq(pot.to_blueprint)
          expect(pot.name).to eq('my square pot')
          expect(pot.shape).to eq('square')
          expect(pot.dimensions).to be_nil
          expect(pot.area).to eq(100.0)
        end

        it 'creates a rectangular pot given its dimensions' do
          post(
            '/api/v1/pots',
            headers:,
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
            headers:,
            params: {
              name: 'my rectangular pot',
              shape: 'rectangle',
              area: '110.0'
            },
            as: :json
          )

          expect(status).to eq(201)

          pot = Pot.last
          expect(response.body).to eq(pot.to_blueprint)
          expect(pot.name).to eq('my rectangular pot')
          expect(pot.shape).to eq('rectangle')
          expect(pot.dimensions).to be_nil
          expect(pot.area).to eq(110.0)
        end

        it 'creates a circular pot given its dimensions' do
          post(
            '/api/v1/pots',
            headers:,
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
          expect(pot.area.to_f).to eq(31.41592653589793)
        end

        it 'creates a circular pot given its area' do
          post(
            '/api/v1/pots',
            headers:,
            params: {
              name: 'my circular pot',
              shape: 'circle',
              area: '120.0'
            },
            as: :json
          )

          expect(status).to eq(201)

          pot = Pot.last
          expect(response.body).to eq(pot.to_blueprint)
          expect(pot.name).to eq('my circular pot')
          expect(pot.shape).to eq('circle')
          expect(pot.dimensions).to be_nil
          expect(pot.area).to eq(120.0)
        end

        it 'creates a triangular pot given its dimensions' do
          post(
            '/api/v1/pots',
            headers:,
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
            headers:,
            params: {
              name: 'my triangular pot',
              shape: 'triangle',
              area: '130.0'
            },
            as: :json
          )

          expect(status).to eq(201)

          pot = Pot.last
          expect(response.body).to eq(pot.to_blueprint)
          expect(pot.name).to eq('my triangular pot')
          expect(pot.shape).to eq('triangle')
          expect(pot.dimensions).to be_nil
          expect(pot.area).to eq(130.0)
        end

        it 'creates an other pot given its area' do
          post(
            '/api/v1/pots',
            headers:,
            params: {
              name: 'my other pot',
              shape: 'other',
              area: '140.0'
            },
            as: :json
          )

          expect(status).to eq(201)

          pot = Pot.last
          expect(response.body).to eq(pot.to_blueprint)
          expect(pot.name).to eq('my other pot')
          expect(pot.shape).to eq('other')
          expect(pot.dimensions).to be_nil
          expect(pot.area).to eq(140.0)
        end
      end
    end

    context 'when 403' do
      it_behaves_like 'with authenticated requester' do
        it 'can\'t create a pot' do
          post('/api/v1/pots', headers:)

          expect(status).to eq(403)
          expect(response.parsed_body.dig('error', 'message')).not_to be_blank
        end
      end
    end

    context 'when 422' do
      it_behaves_like 'with authenticated grower' do
        it 'fails to create a pot with dimensions & invalid shape' do
          post(
            '/api/v1/pots',
            headers:,
            params: {
              name: 'my foobar pot',
              shape: 'foobar',
              dimensions: [12]
            },
            as: :json
          )

          expect(status).to eq(422)
          expect(response.parsed_body.dig('error', 'message')).not_to be_blank
        end

        it 'fails to create an other pot with no `area` given' do
          post(
            '/api/v1/pots',
            headers:,
            params: {
              name: 'my other pot',
              shape: 'other',
              dimensions: [8]
            },
            as: :json
          )

          expect(status).to eq(422)
          expect(response.parsed_body.dig('error', 'message')).not_to be_blank
        end

        it 'fails to create a pot with invalid dimensions number' do
          post(
            '/api/v1/pots',
            headers:,
            params: {
              name: 'my square pot',
              shape: 'square',
              dimensions: [4, 8]
            },
            as: :json
          )

          expect(status).to eq(422)
          expect(response.parsed_body.dig('error', 'message')).not_to be_blank
        end

        it 'fails to create a pot with area & invalid shape' do
          post(
            '/api/v1/pots',
            headers:,
            params: {
              name: 'my foobar pot',
              shape: 'foobar',
              area: '100.0'
            },
            as: :json
          )

          expect(status).to eq(422)
          expect(response.parsed_body.dig('error', 'message')).not_to be_blank
        end
      end
    end
  end

  describe 'PUT api/v1/pots/:id' do
    context 'when 403' do
      it_behaves_like 'with authenticated grower' do
        it 'can\'t update a pot with ongoing requests' do
          put(
            "/api/v1/pots/#{id}",
            headers:,
            params: {
              area: '100.0'
            }
          )

          expect(status).to eq(403)
          expect(response.parsed_body.dig('error', 'message')).not_to be_blank
        end
      end
    end

    context 'when 404' do
      it_behaves_like 'with authenticated requester' do
        it 'can\'t update a pot' do
          put("/api/v1/pots/#{id}", headers:)

          expect(status).to eq(404)
          expect(response.parsed_body.dig('error', 'message')).not_to be_blank
        end
      end
    end
  end

  describe 'DELETE api/v1/pots/:id' do
    context 'when 403' do
      it_behaves_like 'with authenticated grower' do
        it 'can\'t delete a pot with ongoing requests' do
          delete("/api/v1/pots/#{id}", headers:)

          expect(status).to eq(403)
          expect(response.parsed_body.dig('error', 'message')).not_to be_blank
        end
      end
    end

    context 'when 404' do
      it_behaves_like 'with authenticated requester' do
        it 'can\'t delete a pot' do
          delete("/api/v1/pots/#{id}", headers:)

          expect(status).to eq(404)
          expect(response.parsed_body.dig('error', 'message')).not_to be_blank
        end
      end
    end

    context 'when 422' do
      it_behaves_like 'with authenticated grower' do
        before do
          pot.request_distributions.map(&:destroy)
        end

        it 'fails to delete a pot' do
          allow_any_instance_of(Pot).to receive(:destroy).and_return(false)

          delete("/api/v1/pots/#{id}", headers:)

          expect(status).to eq(422)
          expect(response.parsed_body.dig('error', 'message')).not_to be_blank
        end
      end
    end
  end
end
