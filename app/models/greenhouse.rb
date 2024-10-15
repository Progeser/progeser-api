# frozen_string_literal: true
class Greenhouse < ApplicationRecord
  # Associations
  belongs_to :building
  has_many :benches, class_name: 'Bench', inverse_of: :greenhouse, dependent: :destroy

  # Validations
  validates :name, presence: true
  validates :width, :height, numericality: { greater_than: 0 }
  validates :occupancy, inclusion: { in: 0..100 }

  # Public instance methods
  def compute_occupancy
    100
  end
end


# == Schema Information
#
# Table name: greenhouses
#
#  id          :bigint           not null, primary key
#  name        :string           not null
#  width       :integer          not null
#  height      :integer          not null
#  occupancy   :decimal(, )      default(0.0), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  building_id :bigint
#
# Indexes
#
#  index_greenhouses_on_building_id  (building_id)
#
# Foreign Keys
#
#  fk_rails_...  (building_id => buildings.id)
#
