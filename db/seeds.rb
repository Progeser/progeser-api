# frozen_string_literal: true

if Rails.env.development?
  require 'database_cleaner'
  DatabaseCleaner.strategy = :truncation
  DatabaseCleaner.clean

  # Users
  Users::Requester.create!(
    role: :requester,
    email: 'dev+requester@progeser.com',
    password: 'password',
    password_confirmation: 'password',
    first_name: 'Requester',
    last_name: 'ProGeSer',
    laboratory: 'My test lab'
  )

  Users::Grower.create!(
    role: :grower,
    email: 'dev+grower@progeser.com',
    password: 'password',
    password_confirmation: 'password',
    first_name: 'Grower',
    last_name: 'ProGeSer'
  )

  discarded_user = Users::Requester.create!(
    role: :requester,
    email: 'discarded_requester@progeser.com',
    password: 'password',
    password_confirmation: 'password',
    first_name: 'Discarded',
    last_name: 'User',
    laboratory: 'My test lab'
  )
  discarded_user.discard

  # Invites
  Invite.create!(
    role: :requester,
    email: 'invite+requester@progeser.com',
    first_name: 'Requester',
    last_name: 'Invite',
    laboratory: 'My test lab'
  )

  Invite.create!(
    role: :grower,
    email: 'invite+grower@progeser.com',
    first_name: 'Grower',
    last_name: 'Invite'
  )

  # AccountRequests
  AccountRequest.create!(
    email: Faker::Internet.email,
    first_name: Faker::Name.first_name,
    last_name: Faker::Name.last_name,
    comment: Faker::Movies::VForVendetta.speech,
    accepted: true
  )

  AccountRequest.create!(
    email: Faker::Internet.email,
    first_name: Faker::Name.first_name,
    last_name: Faker::Name.last_name,
    comment: Faker::Movies::VForVendetta.speech
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

  Pot.create!(
    name: 'My other pot',
    shape: :other,
    area: 120
  )

  # Greenhouses
  Greenhouse.create!(
    name: 'My big greenhouse',
    width: 1000,
    height: 2000
  )

  Greenhouse.create!(
    name: 'My small greenhouse',
    width: 500,
    height: 500
  )

  # Benches
  Greenhouse.all.each do |greenhouse|
    Bench.create!(
      greenhouse: greenhouse,
      name: "#{greenhouse.name} - bench 1",
      shape: :square,
      dimensions: [5],
      area: 25
    )

    Bench.create!(
      greenhouse: greenhouse,
      name: "#{greenhouse.name} - bench 2",
      shape: :rectangle,
      dimensions: [5, 10],
      area: 50
    )

    Bench.create!(
      greenhouse: greenhouse,
      name: "#{greenhouse.name} - bench 3",
      shape: :other,
      area: 100
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
  Plant.all.each do |plant|
    stage_names.each do |stage_name|
      plant.plant_stages.create!(
        name: stage_name,
        duration: Faker::Number.between(from: 5, to: 30),
        position: stage_names.find_index(stage_name) + 1
      )
    end
  end

  # Requests
  Request.create!(
    author: Users::Requester.first,
    handler: Users::Grower.first,
    plant_stage: Plant.first.plant_stages.last,
    name: 'My first request',
    plant_name: Plant.first.name,
    stage_name: Plant.first.plant_stages.last.name,
    status: :accepted,
    comment: Faker::Movies::LordOfTheRings.quote,
    due_date: Date.current + 3.months,
    quantity: 50,
    temperature: 20,
    photoperiod: 8
  )

  Request.create!(
    author: Users::Requester.first,
    name: 'My new request',
    plant_name: Faker::Food.vegetables,
    stage_name: 'budding',
    comment: Faker::Movies::LordOfTheRings.quote,
    due_date: Date.current + 2.months,
    quantity: 200
  )
end
