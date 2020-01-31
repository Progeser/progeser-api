# frozen_string_literal: true

class Plant < ApplicationRecord
  # Validations
  validates :name, presence: true

  # This seems to not work well with acts_as_list :(
  # See https://github.com/brendon/acts_as_list/issues/367 for details
  #
  # validates :plant_stages,
  #           length: { minimum: 1, message: :at_least_one }

  # Associations
  has_many :plant_stages,
           -> { order(position: :asc) },
           class_name: 'PlantStage',
           foreign_key: 'plant_id',
           inverse_of: :plant,
           dependent: :destroy
  accepts_nested_attributes_for :plant_stages,
                                reject_if: :all_blank,
                                allow_destroy: true
end

# == Schema Information
#
# Table name: plants
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
