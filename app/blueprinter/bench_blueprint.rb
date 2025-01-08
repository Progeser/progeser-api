# frozen_string_literal: true

class BenchBlueprint < Base
  # Fields
  fields :name, :dimensions, :positions, :greenhouse_id

  field :request_distribution_ids do |bench|
    bench.request_distributions.pluck(:id)
  end
end
