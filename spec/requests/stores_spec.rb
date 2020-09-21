require 'rails_helper'

RSpec.describe "Stores", type: :request do
    describe "GET /stores" do
        it "Returns a list of stores" do
            store = FactoryBot.create_list(:store, 4)

            get "/api/v1/stores", params: {latitude: FFaker::Random.rand(1..999999), longitude: FFaker::Random.rand(1..999999)}
            expect(response).to have_http_status(200)
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