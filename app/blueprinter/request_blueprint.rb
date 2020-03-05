# frozen_string_literal: true

class RequestBlueprint < Base
  # Fields
  fields :author_id, :handler_id, :plant_stage_id,
         :name, :plant_name, :plant_stage_name, :status, :quantity, :due_date,
         :comment, :temperature, :photoperiod
end
