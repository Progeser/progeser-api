# frozen_string_literal: true

class Bench < ApplicationRecord
  # Validations
  validates :dimensions,
            presence: true,
            length: { is: 2, message: 'should contain exactly two elements: length and width' }
  validate :dimensions_must_be_positive

  validates_associated :request_distributions,
                       message: 'sum of distributions areas can\'t be greater than bench area'

  # Associations
  belongs_to :greenhouse,
             class_name: 'Greenhouse',
             inverse_of: :benches

  has_many :request_distributions,
           class_name: 'RequestDistribution',
           inverse_of: :bench,
           dependent: :restrict_with_error
  # Checks
  def dimensions_must_be_positive
    return unless dimensions

    return unless dimensions.any? { |d| d <= 0 }

    errors.add(:dimensions, 'each dimension must be greater than 0')
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
