# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api/V1/Shapes', type: :request do
  describe 'GET api/v1/shapes' do
    context 'when 403' do
      it_behaves_like 'with authenticated requester' do
        it 'can\'t get shapes' do
          get('/api/v1/shapes', headers: headers)

          expect(status).to eq(403)
          expect(response.parsed_body.dig('error', 'message')).not_to be_blank
        end
      end
    end
  end
end
