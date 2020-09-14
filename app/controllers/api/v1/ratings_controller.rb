class Api::V1::RatingsController < ApplicationController
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
        @store = Store.new

        @store.lonlat = "POINT(#{params[:store][:latitude].to_f} #{params[:store][:longitude].to_f})"

        @store.name = params[:store][:name]

        if !@store.save!
            render json: {status: 500, message: 'Não foi possível criar a Store!'}
        end
    end

    def ratings_params
        params.require(:rating).permit(:value, :opinion, :user_name)
    end
end
