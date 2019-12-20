# frozen_string_literal: true

require 'acceptance_helper'

resource 'Pots' do
  explanation 'Pots resource'

  header 'Accept',       'application/json'
  header 'Content-Type', 'application/json'

  let!(:user)       { users(:user_2) }
  let!(:user_token) { Doorkeeper::AccessToken.create!(resource_owner_id: user.id) }

  post '/api/v1/pots' do
    parameter :name, 'Name of the pot',  with_example: true
    parameter :shape,
              "Shape of the pot\n\n"\
              'If `other` given, `area` param should be passed',
              with_example: true,
              enum: %w[square rectangle circle triangle other]
    parameter :area,
              "(Optional) Area of the pot (in square centimeters)\n\n"\
              'If used, following `dimensions` parameter will be ignored',
              with_example: true,
              type: :number
    parameter :dimensions,
              '(Optional) Dimensions of the pot (in centimeters)',
              with_example: true,
              type: :array,
              items: {type: :integer}

    let(:name)       { 'my rectangular pot' }
    let(:shape)      { 'rectangle' }
    let(:dimensions) { [10, 20] }

    let(:raw_post) { params.to_json }

    example 'Create a pot with its area' do
      authentication :basic, "Bearer #{user_token.token}"

      do_request

      expect(status).to eq(201)

      expect(response_body).to eq(Pot.last.to_blueprint)

      response = JSON.parse(response_body)
      expect(response.dig('name')).to eq(name)
      expect(response.dig('shape')).to eq(shape)
      expect(response.dig('area')).to eq(dimensions.inject(:*).to_d.to_s)
    end
  end
end
