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

  # Users
  requester_user = Users::Requester.create!(
    role: :requester,
    email: 'dev+requester@progeser.com',
    password: 'password',
    password_confirmation: 'password',
    first_name: 'Requester',
    last_name: 'ProGeSer',
    laboratory: 'My test lab'
  )

  grower_user = Users::Grower.create!(
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
    email: 'accepted_requester@progeser.com',
    first_name: 'Accepted',
    last_name: 'Requester',
    comment: 'This account request has been accepted.',
    accepted: true,
    laboratory: 'Accepted Lab',
    password: 'securepassword'
  )

  AccountRequest.create!(
    email: 'pending_requester@progeser.com',
    first_name: 'Pending',
    last_name: 'Requester',
    comment: 'This account request is pending review.',
    accepted: false,
    laboratory: 'Pending Lab',
    password: 'securepassword'
  )

  # Pots
  pots = [
    { name: 'My square pot', shape: :square, dimensions: [7], area: 49 },
    { name: 'My rectangular pot', shape: :rectangle, dimensions: [8, 10], area: 80 },
    { name: 'My circular pot', shape: :circle, dimensions: [10], area: 10 * Math::PI },
    { name: 'My triangular pot', shape: :triangle, dimensions: [8, 10], area: 40 },
    { name: 'My other pot', shape: :other, area: 120 }
  ]
  pots.each { |pot_attrs| Pot.create!(pot_attrs) }

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
    %w[1 2 3].each do |i|
      Bench.create!(
        greenhouse:,
        name: "#{greenhouse.name} - bench #{i}",
        shape: i == '1' ? :square : (i == '2' ? :rectangle : :other),
        dimensions: i == '1' ? [200] : (i == '2' ? [500, 100] : []),
        area: i == '1' ? 40_000 : (i == '2' ? 50_000 : 100_000)
      )
    end
  end

  # Plants
  plants = 3.times.map do
    Plant.create!(
      name: Faker::Food.vegetables
    )
  end

  # PlantStages
  stage_names = %w[sprout seedling vegetative budding flowering ripening]
  plants.each do |plant|
    stage_names.each_with_index do |stage_name, index|
      plant.plant_stages.create!(
        name: stage_name,
        duration: Faker::Number.between(from: 5, to: 30),
        position: index + 1
      )
    end
  end

  # Requests
  requests = [
    {
      author: grower_user,
      handler: grower_user,
      plant_stage: plants.first.plant_stages.last,
      name: 'My first request',
      plant_name: plants.first.name,
      plant_stage_name: plants.first.plant_stages.last.name,
      comment: Faker::Movies::LordOfTheRings.quote,
      due_date: Date.current + 3.months,
      quantity: 50,
      temperature: 20,
      photoperiod: 8
    },
    {
      author: requester_user,
      name: 'My new request',
      plant_name: Faker::Food.vegetables,
      plant_stage_name: 'budding',
      comment: Faker::Movies::LordOfTheRings.quote,
      due_date: Date.current + 2.months,
      quantity: 200
    }
  ]
  requests.each { |req_attrs| Request.create!(req_attrs) }

  # RequestDistributions
  pots = Pot.limit(2)
  RequestDistribution.create!(
    request: Request.first,
    bench: Bench.first,
    plant_stage: Request.first.plant_stage,
    pot: pots.first,
    pot_quantity: 30,
    area: pots.first.area * 30
  )

  RequestDistribution.create!(
    request: Request.first,
    bench: Bench.first,
    plant_stage: Request.first.plant_stage,
    pot: pots.second,
    pot_quantity: 20,
    area: pots.second.area * 20
  )

  Request.first.update!(status: :accepted)

  RequestDistribution.create!(
    request: Request.second,
    bench: Bench.first,
    plant_stage: plants.second.plant_stages.first,
    area: 100
  )
end
