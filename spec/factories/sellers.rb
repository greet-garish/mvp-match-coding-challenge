FactoryBot.define do
  factory :seller do
    username { Faker::FunnyName.name.parameterize(separator: '_') }
    password { '1234' }

    role { :seller }
  end
end
