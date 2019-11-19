# frozen_string_literal: true

class UserBlueprint < Base
  # Fields
  fields :email, :role, :first_name, :last_name, :laboratory

  # Associations
  view :with_token do
    association :access_tokens,
                name: :token,
                blueprint: TokenBlueprint do |user, _options|
      user.access_tokens.last
    end
  end
end
