# frozen_string_literal: true

class UserBlueprint < Base
  # Fields
  fields :email, :role, :first_name, :last_name, :laboratory

  # Views
  view :with_token do
    association :access_tokens,
                name: :token,
                blueprint: TokenBlueprint
  end
end
