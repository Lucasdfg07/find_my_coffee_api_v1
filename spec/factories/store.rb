FactoryBot.define do
    factory :store do
      lonlat {"POINT(#{FFaker::Random.rand(1..999999)} #{FFaker::Random.rand(1..999999)})"}
      name {FFaker::Name.name}
      address {FFaker::AddressBR.full_address}
      google_place_id {FFaker::Lorem.characters}
    end
  end