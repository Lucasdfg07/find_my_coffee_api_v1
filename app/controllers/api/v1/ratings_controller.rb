class Api::V1::RatingsController < ApplicationController
    before_action :set_store, only: [:show]
    
    def show
    end

    def create
        ActiveRecord::Base.transaction do
            create_store
            create_rating

            render json: {status: 200, message: 'Avaliação enviada com sucesso!'}
        end
    end

    private

    def create_rating
        @rating = Rating.new(ratings_params)

        @rating.store_id = @store.id

        if !@rating.save!
            render json: {status: 500, message: 'Não foi possível criar avaliação!'}
        end
    end

    def create_store
        @store = Store.find_or_create_by(
            lonlat: "POINT(#{params[:store][:latitude].to_f} #{params[:store][:longitude].to_f})",
            name: params[:store][:name],
            address: params[:store][:address],
            google_place_id: params[:store][:place_id]
        )

        if !@store
            render json: {status: 500, message: 'Não foi possível criar a Store!'}
        end
    end

    def set_store
        @store = Store.find_by(google_place_id: params[:id])
    end

    def ratings_params
        params.require(:rating).permit(:value, :opinion, :user_name)
    end
end
