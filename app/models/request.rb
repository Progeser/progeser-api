# frozen_string_literal: true

class Request < ApplicationRecord
  # Enumerize
  extend Enumerize
  enumerize :status,
            in: %i[pending accepted refused],
            default: :pending

  # Validations
  validates :name,
            :status,
            :due_date,
            :quantity,
            :plant_name,
            :stage_name,
            presence: true

  # Associations
  belongs_to :author,
             class_name: 'User',
             foreign_key: 'author_id',
             inverse_of: :authored_requests

  belongs_to :handler,
             class_name: 'Users::Grower',
             foreign_key: 'handler_id',
             inverse_of: :handled_requests,
             optional: true

  belongs_to :plant_stage,
             class_name: 'PlantStage',
             foreign_key: 'plant_stage_id',
             inverse_of: :requests,
             optional: true
end

# == Schema Information
#
# Table name: requests
#
#  id             :bigint           not null, primary key
#  author_id      :bigint
#  handler_id     :bigint
#  plant_stage_id :bigint
#  name           :string
#  plant_name     :string
#  stage_name     :string
#  status         :string
#  comment        :text
#  due_date       :date
#  quantity       :integer
#  temperature    :integer
#  photoperiod    :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_requests_on_author_id       (author_id)
#  index_requests_on_handler_id      (handler_id)
#  index_requests_on_plant_stage_id  (plant_stage_id)
#
