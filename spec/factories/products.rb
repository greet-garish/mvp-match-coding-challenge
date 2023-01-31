FactoryBot.define do
  factory :product do
    name { Faker::Appliance.equipment }
    amount { 1 }
    cost { [*1..3].map { Coins::SUPPORTED.sample }.sum }

    seller { association :seller }
  end
end
