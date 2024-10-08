# frozen_string_literal: true

if Rails.env.development?
  require 'database_cleaner'
  DatabaseCleaner.strategy = :truncation
  DatabaseCleaner.clean

  # Doorkeeper Application for OAuth 2 authentication
  Doorkeeper::Application.find_or_initialize_by(
    name: 'ProGeSer'
  ).update!(
    uid: 'VkU79vCSfXw0rkYEOBbjMWflqsvBbznAr340OZ_3yAU',
    secret: 'Cqzm5WAbDs3Dq8URddDOXdHTFAUOtnqPsAZl-a7vbpQ',
    confidential: false
  )

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
  Greenhouse.find_each do |greenhouse|
    Bench.create!(
      greenhouse:,
      name: "#{greenhouse.name} - bench 1",
      shape: :square,
      dimensions: [200],
      area: 40_000
    )

    Bench.create!(
      greenhouse:,
      name: "#{greenhouse.name} - bench 2",
      shape: :rectangle,
      dimensions: [500, 100],
      area: 50_000
    )

    Bench.create!(
      greenhouse:,
      name: "#{greenhouse.name} - bench 3",
      shape: :other,
      area: 100_000
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
  Request.create!(
    author: Users::Grower.first,
    handler: Users::Grower.first,
    plant_stage: Plant.first.plant_stages.last,
    name: 'My first request',
    plant_name: Plant.first.name,
    plant_stage_name: Plant.first.plant_stages.last.name,
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
    plant_stage_name: 'budding',
    comment: Faker::Movies::LordOfTheRings.quote,
    due_date: Date.current + 2.months,
    quantity: 200
  )

  # RequestDistributions
  RequestDistribution.create!(
    request: Request.first,
    bench: Bench.first,
    plant_stage: Request.first.plant_stage,
    pot: Pot.first,
    pot_quantity: 30,
    area: Pot.first.area * 30
  )

  RequestDistribution.create!(
    request: Request.first,
    bench: Bench.first,
    plant_stage: Request.first.plant_stage,
    pot: Pot.second,
    pot_quantity: 20,
    area: Pot.second.area * 20
  )

  Request.first.update!(status: :accepted)

  RequestDistribution.create!(
    request: Request.second,
    bench: Bench.first,
    plant_stage: Plant.second.plant_stages.first,
    area: 100
  )
end
