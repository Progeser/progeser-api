# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api/V1/Users', type: :request do
  describe 'GET api/v1/users' do
    context 'when 200' do
      it_behaves_like 'with authenticated grower' do
        it 'gets users with pagination params' do
          get(
            '/api/v1/users',
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
          expect(response.headers['Pagination-Total-Pages']).to eq(2)
          expect(response.headers['Pagination-Total-Count']).to eq(3)
        end
      end
    end
  end

  describe 'GET api/v1/users/:id' do
    context 'when 404' do
      it_behaves_like 'with authenticated grower' do
        it 'gets a user' do
          get(
            '/api/v1/users/0',
            headers:
          )

          expect(status).to eq(404)
        end
      end
    end

    context 'when 401' do
      it 'gets a user' do
        get(
          '/api/v1/users/0',
          headers:
        )

        expect(status).to eq(401)
      end
    end
  end

  describe 'POST api/v1/users' do
    context 'when 422' do
      it_behaves_like 'with authenticated grower' do
        it 'returns validation errors' do
          post(
            '/api/v1/users',
            headers:,
            params: {
              user: {
                email: '',
                password: '',
                password_confirmation: '',
                first_name: '',
                last_name: ''
              }
            }
          )
          expect(status).to eq(422)
        end
      end
    end

    context 'when 401' do
      it 'returns unauthorized error' do
        post(
          '/api/v1/users',
          headers: {},
          params: {
            user: {
              email: 'test@test.com',
              password: 'password',
              password_confirmation: 'password',
              first_name: 'Test',
              last_name: 'User'
            }
          }
        )

        expect(status).to eq(401)
      end
    end
  end

  describe 'DELETE api/v1/users/:id' do
    context 'when 404' do
      it_behaves_like 'with authenticated grower' do
        it 'returns not found error' do
          delete(
            '/api/v1/users/0',
            headers:
          )

          expect(status).to eq(404)
        end
      end
    end

    context 'when 401' do
      it 'returns unauthorized error' do
        delete(
          '/api/v1/users/1',
          headers: {}
        )

        expect(status).to eq(401)
      end
    end

    context 'when 422' do
      it_behaves_like 'with authenticated grower' do
        it 'fails to delete user' do
          allow_any_instance_of(User).to receive(:destroy).and_return(false)

          delete(
            '/api/v1/users/1',
            headers:
          )

          expect(status).to eq(422)
        end
      end
    end
  end
end
