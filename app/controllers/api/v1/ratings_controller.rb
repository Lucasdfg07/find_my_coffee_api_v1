class Api::V1::RatingsController < ApplicationController
    def create
        @rating = Rating.new(ratings_params)

        if @rating.save
            render json: {status: 200, message: 'Avaliação enviada com sucesso!'}
        else
            render json: {status: 500, message: 'Não foi possível criar avaliação!'}
        end
    end

    private

    def ratings_params
        params.require(:rating).permit(:store_id, :value, :opinion, :user_name)
    end
end
