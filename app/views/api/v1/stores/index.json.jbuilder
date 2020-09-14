json.array! @stores do |store|
    json.partial! 'store_essential', store: store
    json.ratings_count store.ratings.count
    json.ratings_average store.ratings_average
end