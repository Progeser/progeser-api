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
end
