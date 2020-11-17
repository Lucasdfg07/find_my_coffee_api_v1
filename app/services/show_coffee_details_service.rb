require 'rest-client'
require 'json'

class ShowCoffeeDetailsService
    def initialize(place_id)
        @place_id = place_id
    end
  
    def call
        begin
            base_url = "https://maps.googleapis.com/maps/api/place/details/json?place_id=#{@place_id}&key=YOUT_SECRET_KEY"
            response = RestClient.get base_url
            value = JSON.parse(response.body)
      
        rescue RestClient::ExceptionWithResponse => e
            e.response
        end
    end
end
