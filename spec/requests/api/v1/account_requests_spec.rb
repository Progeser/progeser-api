# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api/V1/AccountRequests', type: :request do
  describe 'POST api/v1/account_requests' do
    context '422' do
      it 'fails to create an account_request with invalid params' do
        post(
          '/api/v1/account_requests',
          params: {
            email: nil,
            first_name: nil,
            last_name: nil,
            comment: nil
          }
        )

        expect(status).to eq(422)
        expect(JSON.parse(response.body).dig('error', 'message')).not_to be_blank
      end
    end
  end
end
