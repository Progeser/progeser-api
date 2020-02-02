# frozen_string_literal: true

class Base < Blueprinter::Base
  identifier :id

  fields :created_at, :updated_at

  def self.serialize_other_shape
    { name: 'other', display_name: I18n.t('shape.other') }
  end
end
