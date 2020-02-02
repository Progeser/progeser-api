# frozen_string_literal: true

class Greenhouse < ApplicationRecord
  # Validations
  validates :name, presence: true

  validates :width,
            :height,
            numericality: { greater_than: 0 }

  validates :occupancy, inclusion: { in: 0..100 }

  # Associations
  has_many :benches,
           class_name: 'Bench',
           foreign_key: 'greenhouse_id',
           inverse_of: :greenhouse,
           dependent: :destroy

  # Public instance methods
  # TODO: complete this method when request distributions will be created
  def compute_occupancy
    100
  end
end

# == Schema Information
#
# Table name: greenhouses
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  width      :integer          not null
#  height     :integer          not null
#  occupancy  :float            default(0.0), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
