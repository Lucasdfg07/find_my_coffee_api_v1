json.array! @stores do |store|
    json.id store.id
    json.lonlat store.lonlat
    json.name store.name
    json.ratings_count store.ratings.count
    json.ratings_average store.ratings_average
end