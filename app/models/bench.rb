# frozen_string_literal: true

class Bench < ApplicationRecord
  # Enumerize
  extend Enumerize
  enumerize :shape,
            in: Pot.shape.values

  # Validations
  validates :shape,
            :dimensions,
            presence: true

  validates :area, numericality: { greater_than: 0 }

  validate :valid_dimensions_number

  # Associations
  belongs_to :greenhouse,
             class_name: 'Greenhouse',
             foreign_key: 'greenhouse_id',
             inverse_of: :benches

  # Public instance methods
  def valid_dimensions_number
    return false unless shape && dimensions

    current_number = dimensions.length
    expected_number = "Shape::#{shape.capitalize}::DIMENSIONS_NAMES".constantize.length

    return true if current_number == expected_number

    errors.add(
      :dimensions,
      "Dimensions number is incorrect (given #{current_number}, expected #{expected_number})"
    )
  end
end

# == Schema Information
#
# Table name: benches
#
#  id            :bigint           not null, primary key
#  greenhouse_id :bigint
#  name          :string
#  shape         :string           not null
#  area          :decimal(, )      not null
#  dimensions    :integer          is an Array
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_benches_on_greenhouse_id  (greenhouse_id)
#
