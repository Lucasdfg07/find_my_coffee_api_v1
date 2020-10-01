class Store < ApplicationRecord
    has_many :ratings

    validates_presence_of :lonlat, :name
    
    scope :within, -> (latitude, longitude, distance_in_mile = 18000) {
        where(%{
            ST_Distance(lonlat, 'POINT(%f %f)') < %d
        } % [longitude, latitude, distance_in_mile * 1609.34])
    }

    def ratings_average
        (self.ratings.sum(:value) / self.ratings.count).to_i if ratings.count > 0
    end
end
