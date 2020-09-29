require 'rails_helper'

RSpec.describe "Ratings", type: :request do
    before do
        @store = FactoryBot.create(:store)
        @rating = FactoryBot.create(:rating, store_id: @store.id)
    end

    describe "GET /ratings/:id" do
        context 'Store exists' do
            before { @store = FactoryBot.create(:store) }

            context 'Ratings exists' do
                before do
                    @ratings = []

                    rand(1..10).times do 
                        @ratings << FactoryBot.create(:rating, store_id: @store.id)
                    end
                    
                    get "/api/v1/ratings/#{@store.google_place_id}"
                end

                it { expect(response).to have_http_status(200) }

                it "Returns the rating count correctly" do
                    expect(JSON.parse(response.body)['ratings_count']).to eq(@ratings.count)
                end

                it "Returns the rating average correctly" do
                    get "/api/v1/ratings/#{@store.google_place_id}"
                    expect(JSON.parse(response.body)['ratings_average']).to eq(@ratings.map(&:value).sum / @ratings.count)
                end
            end

            context "Ratings doesn't exists" do
                before { get "/api/v1/ratings/#{@store.google_place_id}" }

                it { expect(response).to have_http_status(200) }

                it "Returns the rating empty" do
                    expect(JSON.parse(response.body)['ratings']).to be_empty
                end

                it "Returns the count equal 0" do
                    expect(JSON.parse(response.body)['ratings_count']).to eql(0)
                end
            end 
        end

        context "Store doesn't exists" do
            it "Returns status 404" do
                get "/api/v1/ratings/0000"
                
                expect(response).to have_http_status(404)
            end
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