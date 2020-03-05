# frozen_string_literal: true

class RenameStageNameToPlantStageNameInRequests < ActiveRecord::Migration[6.0]
  def change
    rename_column :requests, :stage_name, :plant_stage_name
  end
end
