FactoryBot.define do
  factory :user do
    username { Faker::FunnyName.name.underscore }
    password { '1234' }

    trait :seller do
      role { :seller }
      type { 'Seller' }
    end

    trait :buyer do
      role { :buyer }
      type { 'Buyer' }
    end
  end
end
