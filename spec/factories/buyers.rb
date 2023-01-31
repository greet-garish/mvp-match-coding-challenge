FactoryBot.define do
  factory :buyer do
    username { Faker::FunnyName.name.parameterize(separator: '_') }
    password { '1234' }

    role { 0 }
    deposit { 0 }
  end
end
