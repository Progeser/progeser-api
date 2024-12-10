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

  validates_associated :request_distributions, if: :dimensions_and_positions_valid?

  validate :overlapping_bench_exists, on: %i[create update]

  validate :distributions_areas_lower_than_bench_area, on: %i[update]

  # Associations
  belongs_to :greenhouse,
             class_name: 'Greenhouse',
             inverse_of: :benches

  has_many :request_distributions,
           class_name: 'RequestDistribution',
           inverse_of: :bench,
           dependent: :restrict_with_error
  # Checks
  def distributions_areas_lower_than_bench_area
    return if errors[:dimensions].any?

    if request_distributions.any? do |request_distribution|
      width1, height1 = dimensions
      x2, y2 = request_distribution.positions_on_bench
      width2, height2 = request_distribution.dimensions

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

    if greenhouse.benches.any? do |other_bench|
      next if other_bench == self

      positions_overlap?(other_bench)
    end
      errors.add(:positions, 'bench overlaps with an existing bench')
    end
  end

  def positions_overlap?(other_bench)
    x1, y1 = positions
    width1, height1 = dimensions
    x2, y2 = other_bench.positions
    width2, height2 = other_bench.dimensions

    x1 < x2 + width2 && x1 + width1 > x2 && y1 < y2 + height2 && y1 + height1 > y2
  end

  def dimensions_and_positions_valid?
    errors[:dimensions].empty? && errors[:positions].empty?
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
