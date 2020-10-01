require 'rest-client'
require 'json'

class AllCoffeesService
    def initialize(latitude, longitude)
        @latitude = latitude
        @longitude = longitude
    end
  
    def call
        begin
            base_url = "https://maps.googleapis.com/maps/api/place/textsearch/json?query=coffee+shop&location=-#{@latitude},#{@longitude}&radius=5000&key=AIzaSyAriO9z5tX1tht7YomsgWyC9BNpWMT599w"
            response = RestClient.get base_url
            value = JSON.parse(response.body)
      
        rescue RestClient::ExceptionWithResponse => e
            e.response
        end
    end
end