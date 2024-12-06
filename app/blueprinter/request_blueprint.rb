# frozen_string_literal: true

class RequestBlueprint < Base
  # Fields
  fields :handler_id, :plant_stage_id,
         :name, :plant_name, :plant_stage_name, :status, :quantity, :due_date,
         :comment, :temperature, :photoperiod,
         :requester_first_name, :requester_last_name, :requester_email, :laboratory

  field :plant_id do |request|
    request.plant&.id
  end
end
