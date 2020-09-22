require 'rails_helper'

RSpec.describe "Ratings", type: :request do
    before do
        @store = FactoryBot.create(:store)
        @rating = FactoryBot.create(:rating, store_id: @store.id)
    end

    describe "GET /ratings/:id" do
        it "Returns the store and these ratings by google_place_id" do
            get "/api/v1/ratings/#{@store.google_place_id}"
            expect(response).to have_http_status(200)
        end
    end

    describe "POST /ratings" do
        it "Create rating and store" do
            post "/api/v1/ratings", params: {
                                        store: {
                                            latitude: FFaker::Random.rand(1..999999),
                                            longitude: FFaker::Random.rand(1..999999),
                                            name: FFaker::Name.name,
                                            address: FFaker::AddressBR.full_address,
                                            google_place_id: FFaker::Lorem.characters
                                        }, 
                                        rating: {
                                            value: FFaker::Random.rand(1..5), 
                                            opinion: FFaker::Lorem.paragraph, 
                                            user_name: FFaker::Name.name
                                        }
                                    }
                                            
            expect(response).to have_http_status(200)
        end
    end
end