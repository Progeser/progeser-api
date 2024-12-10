# frozen_string_literal: true

if Rails.env.development?
  require 'database_cleaner'
  DatabaseCleaner.strategy = :truncation
  DatabaseCleaner.clean

  Doorkeeper::Application.find_or_initialize_by(
    name: 'Uniser'
  ).update!(
    uid: 'VkU79vCSfXw0rkYEOBbjMWflqsvBbznAr340OZ_3yAU',
    secret: 'Cqzm5WAbDs3Dq8URddDOXdHTFAUOtnqPsAZl-a7vbpQ',
    confidential: false
  )

  User.create!(
    email: 'dev+grower@progeser.com',
    password: 'password',
    password_confirmation: 'password',
    first_name: 'Utilisateur',
    last_name: 'Progeser'
  )

  User.create!(
    email: 'utilisateur@uniser.com',
    password: 'superpassword',
    password_confirmation: 'superpassword',
    first_name: 'Utilisateur',
    last_name: 'Uniser'
  )

  User.create!(
    email: 'bob.martin@uniser.com',
    password: 'password_bob',
    password_confirmation: 'password_bob',
    first_name: 'Bob',
    last_name: 'Martin'
  )

  # Pots
  10.times do |i|
    shapes = %i[square rectangle circle]
    shape = shapes.sample
    dimensions =
      case shape
      when :square, :circle then [rand(5..20)]
      when :rectangle then [rand(5..20), rand(5..20)]
      else
        raise "Unknown shape: #{shape}"
      end
    area =
      case shape
      when :square then dimensions[0]**2
      when :rectangle then dimensions[0] * dimensions[1]
      when :circle then (dimensions[0]**2) * Math::PI
      else
        raise "Unknown shape: #{shape}"
      end

    Pot.create!(
      name: "Pot #{i + 1} - #{shape}",
      shape: shape,
      dimensions: dimensions,
      area: area
    )
  end

  # Bâtiments
  building1 = Building.create!(
    name: 'Bâtiment Principal',
    description: 'Le bâtiment principal de la serre.'
  )

  Building.create!(
    name: 'Bâtiment Annexe',
    description: 'Un bâtiment annexe de la serre.'
  )

  Building.create!(
    name: 'Extension',
    description: 'Une extension de la serre.'
  )

  Building.create!(
    name: 'Extérieur',
    description: 'Un espace extérieur de la serre.'
  )

  # Serres
  greenhouse1 = building1.greenhouses.create!(
    name: 'Grande serre principale',
    width: 2000,
    height: 1000
  )

  greenhouse2 = building1.greenhouses.create!(
    name: 'Petite serre principale',
    width: 1000,
    height: 500
  )

  building1.greenhouses.create!(
    name: 'Serre de recherche',
    width: 500,
    height: 500
  )

  building1.greenhouses.create!(
    name: 'Serre de production',
    width: 500,
    height: 300
  )

  # Benchs pour greenhouse1 (Grande serre principale)
  Bench.create!(
    greenhouse: greenhouse1,
    name: "Table 1 - #{greenhouse1.name}",
    dimensions: [500, 200],
    positions: [0, 0]
  )

  Bench.create!(
    greenhouse: greenhouse1,
    name: "Table 2 - #{greenhouse1.name}",
    dimensions: [300, 150],
    positions: [600, 0]
  )

  Bench.create!(
    greenhouse: greenhouse1,
    name: "Table 3 - #{greenhouse1.name}",
    dimensions: [200, 200],
    positions: [600, 300]
  )

  Bench.create!(
    greenhouse: greenhouse1,
    name: "Table 4 - #{greenhouse1.name}",
    dimensions: [200, 200],
    positions: [600, 550]
  )

  # Benchs pour greenhouse2 (Petite serre principale)
  Bench.create!(
    greenhouse: greenhouse2,
    name: "Table 1 - #{greenhouse2.name}",
    dimensions: [300, 300],
    positions: [0, 0]
  )

  Bench.create!(
    greenhouse: greenhouse2,
    name: "Table 2 - #{greenhouse2.name}",
    dimensions: [400, 200],
    positions: [400, 0]
  )

  Bench.create!(
    greenhouse: greenhouse2,
    name: "Table 3 - #{greenhouse2.name}",
    dimensions: [200, 200],
    positions: [810, 200]
  )

  # Plantes
  plant_names = %w[Fougère Orchidée Lavande Lys Géranium Hibiscus Violette Camélia Jasmin Magnolia]

  plant_names.each do |name|
    Plant.create!(
      name: name
    )
  end

  # Étapes des plantes
  stage_names = %w[germe plantule végétative bourgeonnement floraison maturation]
  Plant.find_each do |plant|
    stage_names.each do |stage_name|
      plant.plant_stages.create!(
        name: stage_name,
        duration: rand(5..30),
        position: stage_names.index(stage_name) + 1
      )
    end
  end

  # Requests
  requests = []
  5.times do |i|
    plant = Plant.order('RANDOM()').first
    plant_stage = plant.plant_stages.order('RANDOM()').first
    requests << Request.create!(
      requester_first_name: Faker::Name.first_name,
      requester_last_name: Faker::Name.last_name,
      requester_email: Faker::Internet.email,
      laboratory: Faker::Science.scientist,
      handler: User.first,
      plant_stage: plant_stage,
      name: "Requête #{i + 1}",
      plant_name: plant.name,
      plant_stage_name: plant_stage.name,
      comment: Faker::Lorem.sentence,
      due_date: Date.current + rand(1..6).months,
      quantity: rand(10..100),
      temperature: %w[Chaud Froid Extérieur].sample,
      photoperiod: rand(6..18),
      status: %i[pending refused completed].sample
    )
  end

  def distribute_request(request)
    return unless request_pending_or_accepted?(request)

    bench, pot = select_random_bench_and_pot
    distribution_details = prepare_distribution_details(request, bench)

    handle_distribution(
      request: request,
      bench: bench,
      pot: pot,
      distribution_details: distribution_details
    )
  end

  def request_pending_or_accepted?(request)
    %w[pending accepted].include?(request.status)
  end

  def select_random_bench_and_pot
    [Bench.order('RANDOM()').first, Pot.order('RANDOM()').first]
  end

  def prepare_distribution_details(request, bench)
    dimensions = [rand(50..200), rand(50..200)]
    position = find_position_for_request(bench, dimensions)
    distributed_quantity = rand(1..request.quantity)

    {
      dimensions: dimensions,
      position: position,
      quantity: distributed_quantity,
      total_quantity: request.quantity
    }
  end

  def find_position_for_request(bench, dimensions)
    occupied_positions = []
    find_available_position(bench, dimensions, occupied_positions)
  end

  def handle_distribution(request:, bench:, pot:, distribution_details:)
    if distribution_details[:position]
      create_distribution_record(
        request: request,
        bench: bench,
        pot: pot,
        details: distribution_details
      )
    end

    update_request_status(request, distribution_details[:quantity], distribution_details[:total_quantity])
  end

  def create_distribution_record(request:, bench:, pot:, details:)
    create_request_distribution(
      request: request,
      bench: bench,
      pot: pot,
      plant_stage: request.plant_stage,
      quantity: details[:quantity],
      position: details[:position],
      dimensions: details[:dimensions]
    )
  end

  def find_available_position(bench, dimensions, occupied_positions)
    max_attempts = 10

    max_attempts.times do
      position = [
        rand(0..(bench.dimensions[0] - dimensions[0])),
        rand(0..(bench.dimensions[1] - dimensions[1]))
      ]

      overlapping = occupied_positions.any? do |occupied|
        overlap?(position, dimensions, occupied)
      end

      return position unless overlapping
    end

    nil
  end

  def overlap?(position, dimensions, occupied)
    ox, oy, ow, oh = occupied
    px, py = position
    pw, ph = dimensions

    !(px + pw <= ox || px >= ox + ow || py + ph <= oy || py >= oy + oh)
  end

  def create_request_distribution(distribution_params)
    RequestDistribution.create!(
      request: distribution_params[:request],
      bench: distribution_params[:bench],
      plant_stage: distribution_params[:plant_stage],
      pot: distribution_params[:pot],
      pot_quantity: distribution_params[:quantity],
      positions_on_bench: distribution_params[:position],
      dimensions: distribution_params[:dimensions]
    )
  end

  def update_request_status(request, distributed_quantity, total_quantity)
    if distributed_quantity < total_quantity
      request.update!(status: 'pending')
    else
      request.update!(status: 'accepted')
    end
  end

  requests.each { |request| distribute_request(request) }
end