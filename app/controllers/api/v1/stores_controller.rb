class Api::V1::StoresController < ApplicationController
    before_action :set_store, only: [:show]

    def index
        @stores = Store.within(params[:latitude].to_f, params[:longitude].to_f)
    end

    private

    def set_store
        @store = Store.find(params[:id])
    end
end
