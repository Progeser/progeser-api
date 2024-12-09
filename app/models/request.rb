# frozen_string_literal: true

class Request < ApplicationRecord
  # Enumerize
  extend Enumerize
  enumerize :status,
            in: %i[pending accepted refused in_cancelation canceled completed],
            default: :pending

  # Validations
  validates :name,
            :status,
            :due_date,
            :quantity,
            :plant_name,
            :plant_stage_name,
            :requester_first_name,
            :requester_last_name,
            :requester_email,
            presence: true

  validates :requester_email, format: { with: URI::MailTo::EMAIL_REGEXP }

  # Associations
  belongs_to :handler,
             class_name: 'Users::Grower',
             inverse_of: :handled_requests,
             optional: true

  belongs_to :plant_stage,
             class_name: 'PlantStage',
             inverse_of: :requests,
             optional: true

  has_one :plant,
          class_name: 'Plant',
          through: :plant_stage

  has_many :request_distributions,
           class_name: 'RequestDistribution',
           inverse_of: :request,
           dependent: :destroy

  # State Machine
  state_machine initial: :pending, attribute: :status do
    event :accept do
      transition pending: :accepted
    end

    event :refuse do
      transition pending: :refused
    end

    event :cancel_request do
      transition accepted: :in_cancelation
    end

    event :cancel do
      transition %i[pending accepted in_cancelation] => :canceled
    end

    event :complete do
      transition accepted: :completed
    end

    state :accepted do
      validates :request_distributions,
                length: { minimum: 1, message: :at_least_one }
      validates :plant_stage, presence: true
    end
  end
end

# == Schema Information
#
# Table name: requests
#
#  id                   :bigint           not null, primary key
#  handler_id           :bigint
#  plant_stage_id       :bigint
#  name                 :string
#  plant_name           :string
#  plant_stage_name     :string
#  status               :string
#  comment              :text
#  due_date             :date
#  quantity             :integer
#  temperature          :integer
#  photoperiod          :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  requester_first_name :string           default(""), not null
#  requester_last_name  :string           default(""), not null
#  requester_email      :string           default(""), not null
#  laboratory           :string
#
# Indexes
#
#  index_requests_on_handler_id      (handler_id)
#  index_requests_on_plant_stage_id  (plant_stage_id)
#
