FactoryBot.define do
    factory :rating do
      value {FFaker::Random.rand(1..5)}
      opinion {FFaker::Lorem.paragraph}
      user_name {FFaker::Name.name}
    end
  end