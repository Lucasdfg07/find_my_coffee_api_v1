class Api::V1::StoresController < ApplicationController
    before_action :set_store, only: [:show]

    def index
        if !params[:latitude].nil? && !params[:longitude].nil?
            @stores = Store.within(params[:latitude].to_f, params[:longitude].to_f)
                            .sort_by { |store| store.ratings_average }
                            .reverse
        else
            []
        end
    end

    def show
    end

    private

    def set_store
        @store = Store.find(params[:id])
    end
end
