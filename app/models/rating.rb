class Rating < ApplicationRecord
    validates_presence_of :value, :opinion, :user_name
end
