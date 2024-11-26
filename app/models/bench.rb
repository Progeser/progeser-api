# frozen_string_literal: true

class Bench < ApplicationRecord
  # Validations
  validates :dimensions,
            presence: true,
            length: { is: 2, message: I18n.t('activerecord.errors.models.bench.attributes.dimensions.incorrect_size') }
  validate :dimensions_must_be_strictly_positive

  validates :positions,
            presence: true,
            length: { is: 2, message: I18n.t('activerecord.errors.models.bench.attributes.positions.incorrect_size') }
  validate :positions_must_be_positive

  validate :overlapping_bench_exists, on: %i[create update]

  validate :distributions_areas_lower_than_bench_area, on: %i[update]

  # Associations
  belongs_to :greenhouse,
             class_name: 'Greenhouse',
             inverse_of: :benches

  has_many :distributions,
           class_name: 'Distribution',
           inverse_of: :bench,
           dependent: :restrict_with_error

  # Checks
  def distributions_areas_lower_than_bench_area
    return if errors[:dimensions].any?

    if distributions.any? do |distribution|
      width1, height1 = dimensions
      x2, y2 = distribution.positions_on_bench
      width2, height2 = distribution.dimensions

      width1 < x2 + width2 || height1 < y2 + height2
    end
      errors.add(:dimensions, 'sum of distributions areas can\'t be greater than bench area')
    end
  end

  def dimensions_must_be_strictly_positive
    return unless dimensions

    return unless dimensions.any? { |d| d <= 0 }

    errors.add(:dimensions, 'each dimension must be greater than 0')
  end

  def positions_must_be_positive
    return unless positions

    return unless positions.any?(&:negative?)

    errors.add(:positions, 'each position must be positive')
  end

  def overlapping_bench_exists
    return if errors[:dimensions].any? || errors[:positions].any?
    return unless greenhouse

    new_bench_position = positions
    new_bench_dimensions = dimensions

    if greenhouse.benches.any? do |bench|
      next if bench == self

      existing_bench_position = bench.positions
      existing_bench_dimensions = bench.dimensions

      positions_overlap?(new_bench_position, new_bench_dimensions, existing_bench_position, existing_bench_dimensions)
    end
      errors.add(:positions, 'bench overlaps with an existing bench')
    end
  end

  def positions_overlap?(pos1, dim1, pos2, dim2)
    x1, y1 = pos1
    width1, height1 = dim1
    x2, y2 = pos2
    width2, height2 = dim2

    x1 < x2 + width2 && x1 + width1 > x2 && y1 < y2 + height2 && y1 + height1 > y2
  end
end

# == Schema Information
#
# Table name: benches
#
#  id            :bigint           not null, primary key
#  greenhouse_id :bigint
#  name          :string
#  dimensions    :integer          is an Array
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  positions     :integer          is an Array
#
# Indexes
#
#  index_benches_on_greenhouse_id  (greenhouse_id)
#
