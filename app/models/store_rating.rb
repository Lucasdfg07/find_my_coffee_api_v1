class StoreRating < ApplicationRecord
    belongs_to :rating
    belongs_to :store
end
