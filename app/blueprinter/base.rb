# frozen_string_literal: true

class Base < Blueprinter::Base
  identifier :id

  fields :created_at, :updated_at
end
