class Api::V1::StoresController < ApplicationController
    before_action :set_store, only: [:show]

    def show
    end

    def search_stores_in_geolocation
        @stores = Store.within(params[:latitude].to_f, params[:longitude].to_f, 5000)
    end

    private

    def set_store
        @store = Store.find(params[:id])
    end
end