# frozen_string_literal: true

if Rails.env.development?
  require 'database_cleaner'
  DatabaseCleaner.strategy = :truncation
  DatabaseCleaner.clean

  Doorkeeper::Application.find_or_initialize_by(
    name: 'ProGeSer'
  ).update!(
    uid: 'VkU79vCSfXw0rkYEOBbjMWflqsvBbznAr340OZ_3yAU',
    secret: 'Cqzm5WAbDs3Dq8URddDOXdHTFAUOtnqPsAZl-a7vbpQ',
    confidential: false
  )

  User.create!(
    email: 'dev+grower@progeser.com',
    password: 'password',
    password_confirmation: 'password',
    first_name: 'Grower',
    last_name: 'ProGeSer'
  )

  # Pots
  Pot.create!(
    name: 'My square pot',
    shape: :square,
    dimensions: [7],
    area: 49
  )

  Pot.create!(
    name: 'My rectangular pot',
    shape: :rectangle,
    dimensions: [8, 10],
    area: 80
  )

  Pot.create!(
    name: 'My circular pot',
    shape: :circle,
    dimensions: [10],
    area: 10 * Math::PI
  )

  Pot.create!(
    name: 'My triangular pot',
    shape: :triangle,
    dimensions: [8, 10],
    area: 40
  )

  building1 = Building.create!(
    name: 'Main Building',
    description: 'The main building that houses the primary operations.'
  )

  Building.create!(
    name: 'Secondary Building',
    description: 'A secondary building for auxiliary functions and storage.'
  )

  # Greenhouses
  greenhouse1 = building1.greenhouses.create!(
    name: 'My big greenhouse',
    width: 1000,
    height: 2000
  )

  greenhouse2 = building1.greenhouses.create!(
    name: 'My small greenhouse',
    width: 500,
    height: 500
  )

  # Benches
  [greenhouse1, greenhouse2].each do |greenhouse|
    Bench.create!(
      greenhouse:,
      name: "#{greenhouse.name} - bench 1",
      dimensions: [200, 200],
      positions: [200, 10]
    )

    Bench.create!(
      greenhouse:,
      name: "#{greenhouse.name} - bench 2",
      dimensions: [500, 100],
      positions: [200, 400]
    )

    Bench.create!(
      greenhouse:,
      name: "#{greenhouse.name} - bench 3",
      dimensions: [50, 100],
      positions: [400, 200]
    )
  end

  # Plants
  3.times do
    Plant.create!(
      name: Faker::Food.vegetables
    )
  end

  # PlantStages
  stage_names = %w[sprout seedling vegetative budding flowering ripening]
  Plant.find_each do |plant|
    stage_names.each do |stage_name|
      plant.plant_stages.create!(
        name: stage_name,
        duration: Faker::Number.between(from: 5, to: 30),
        position: stage_names.find_index(stage_name) + 1
      )
    end
  end

  # Requests
  # db/seeds.rb

  Request.create!(
    requester_first_name: 'John',
    requester_last_name: 'Doe',
    requester_email: 'john.doe@example.com',
    laboratory: 'My lab',
    handler: User.first,
    plant_stage: Plant.first.plant_stages.last,
    name: 'My first request',
    plant_name: Plant.first.name,
    plant_stage_name: Plant.first.plant_stages.last.name,
    comment: Faker::Movies::LordOfTheRings.quote,
    due_date: Date.current + 3.months,
    quantity: 50,
    temperature: 'Chaud',
    photoperiod: 8
  )

  Request.create!(
    requester_first_name: 'Alice',
    requester_last_name: 'Smith',
    requester_email: 'alice.smith@example.com',
    laboratory: 'My other lab',
    name: 'My new request',
    plant_name: Plant.last.name,
    plant_stage_name: Plant.last.plant_stages.last.name,
    plant_stage: Plant.last.plant_stages.last,
    comment: Faker::Movies::LordOfTheRings.quote,
    due_date: Date.current + 2.months,
    quantity: 200,
    temperature: 'Froid',
    photoperiod: 16
  )

  # RequestDistributions
  RequestDistribution.create!(
    request: Request.first,
    bench: Bench.first,
    plant_stage: Request.first.plant_stage,
    pot: Pot.first,
    pot_quantity: 30,
    positions_on_bench: [0, 0],
    dimensions: [50, 50]
  )

  RequestDistribution.create!(
    request: Request.first,
    bench: Bench.first,
    plant_stage: Request.first.plant_stage,
    pot: Pot.second,
    pot_quantity: 20,
    positions_on_bench: [100, 50],
    dimensions: [50, 20]
  )

  Request.first.update!(status: :accepted)

  RequestDistribution.create!(
    request: Request.second,
    bench: Bench.second,
    plant_stage: Request.second.plant_stage,
    pot: Pot.second,
    pot_quantity: 20,
    positions_on_bench: [0, 10],
    dimensions: [20, 30]
  )
end
