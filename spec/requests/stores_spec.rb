require 'rails_helper'

RSpec.describe "Stores", type: :request do
    describe "GET /stores" do
        before do
            (10).times do
                @store = FactoryBot.create(:store)
                @rating = FactoryBot.create(:rating, store_id: @store.id)
            end
        end

        context "Stores exists" do
            before do 
                get "/api/v1/stores", params: {latitude: -21.7412678, longitude: -41.3549968}
            end
            
            it { expect(response).to have_http_status(200) }
            
            it "Return stores near of user" do
                expect(JSON.parse(response.body).count).to be > 0
            end

            it "Verify if is ordered by rating average" do
                JSON.parse(response.body).each_with_index do |store, index|
                    if index > 0
                        expect(@last_store["ratings_average"]).to be >= store["ratings_average"]
                    end

                    @last_store = store
                end
            end
        end

        context "Stores don't exist" do
            before do 
                get "/api/v1/stores", params: {latitude: nil, longitude: nil}
            end

            it { expect(response).to have_http_status(200) }

            it "Returns an empty array" do
                expect(JSON.parse(response.body)).to eq([])
            end
        end
    end

    describe "GET /stores/:id" do
        it "Returns the correct store" do
            store = FactoryBot.create(:store)

            get "/api/v1/stores/#{store.id}"
            expect(response.body).to include(store.name, store.address)
        end
    end
end