json.ratings @store.ratings do |rating|
    json.value rating.value
    json.opinion rating.opinion
    json.user_name rating.user_name
    json.date rating.created_at.strftime("%d/%m/%Y")
end

json.ratings_count @store.ratings.count
json.ratings_average @store.ratings.sum(:value) / @store.ratings.count