## 1 - Criando a API do nosso Projeto (Find My Coffee)

### Criando nosso Projeto

1 - Para começarmos, crie uma pasta chamada find_my_coffee.

2 - Dentro dela, vamos criar nosso projeto rails com o seguinte comando:
```
rails new api --database=postgresql
```

ou até melhor:

```
rails new api --api  --database=postgresql
```

### Instalando o Postgis

#### MacOS
Use o comando abaixo:
```
brew install postgis
```

#### Windows
Baixe o instalador no link abaixo e selecione para a instalação do Postgis conjunta:
```
https://www.postgresql.org/download/
```

Dica: Use o tutorial do link https://qastack.com.br/gis/41060/how-to-install-postgis-on-windows


#### Linux

Utilize o comando abaixo para verificar a versão de seu Postgres:
```
$ apt-cache policy postgresql
postgresql:
Instalado: 8.X.10-0squeeze1
Candidato: 8.X.10-0squeeze1
Tabela de versão:
*** 8.X.10-0squeeze1 0
```

Após isso, instale o Postgis referente à sua versão do Postgres:

```
sudo apt-get install postgresql-8.X-postgis postgis
```

Link de instalação: https://concani3.wordpress.com/2012/02/26/instalar-postgis-no-linux-debian/

### Testes RSpec

1 - Vamos colocar as seguintes gems em nosso Gemfile, no grupo :development, :test:

```
gem 'rspec-rails', '~> 3.8'
gem 'ffaker'
gem 'factory_bot_rails'
```

2 - Rode um bundle install

3 - Finalizando, rode o seguinte comando para gerar nosso spec:

```
rails generate rspec:install
```

4 - Agora navegue até a pasta '/spec' e substitua o seguinte código no spec_helper.rb:

```
require 'factory_bot'

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
end
```

5 - Agora navegue no rails_helper.rb e cole o seguinte código:

```
require 'spec_helper'

ENV['RAILS_ENV'] ||= 'test'

require File.expand_path('../config/environment', __dir__)

abort("The Rails environment is running in production mode!") if Rails.env.production?

require 'rspec/rails'

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end

RSpec.configure do |config|
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  config.use_transactional_fixtures = true

  config.infer_spec_type_from_file_location!

  config.filter_rails_from_backtrace!
end
```

6 - Agora a pasta '/spec/factories'.

7 - Dentro da pasta 'factories', crie os arquivos rating.rb e store.rb.

8 - Dentro do arquivo /spec/factories/rating.rb, cole o seguinte código:

```
FactoryBot.define do
    factory :rating do
      value {FFaker::Random.rand(1..5)}
      opinion {FFaker::Lorem.paragraph}
      user_name {FFaker::Name.name}
    end
  end
```

9 - Agora dentro do arquivo /spec/factories/store.rb, cole o seguinte código:

```
FactoryBot.define do
    factory :store do
      lonlat {"POINT(#{FFaker::Random.rand(1..999999)} #{FFaker::Random.rand(1..999999)})"}
      name {FFaker::Name.name}
      address {FFaker::AddressBR.full_address}
      google_place_id {FFaker::Lorem.characters}
    end
  end
```

10 - Agora crie a pasta '/spec/requests'.

11 - Entre na pasta 'requests' e crie os arquivos ratings_spec.rb e o stores_spec.rb.

12 - Dentro do arquivo ratings_spec.rb, cole o seguinte código:

```
require 'rails_helper'

RSpec.describe "Ratings", type: :request do
    before do
        @store = FactoryBot.create(:store)
        @rating = FactoryBot.create(:rating, store_id: @store.id)
    end

    describe "GET /ratings/:id" do
        context 'Store exists' do
            before { @store = FactoryBot.create(:store) }

            context 'Ratings exists' do
                before do
                    @ratings = []

                    rand(1..10).times do 
                        @ratings << FactoryBot.create(:rating, store_id: @store.id)
                    end
                    
                    get "/api/v1/ratings/#{@store.google_place_id}"
                end

                it { expect(response).to have_http_status(200) }

                it "Returns the rating count correctly" do
                    expect(JSON.parse(response.body)['ratings_count']).to eq(@ratings.count)
                end

                it "Returns the rating average correctly" do
                    get "/api/v1/ratings/#{@store.google_place_id}"
                    expect(JSON.parse(response.body)['ratings_average']).to eq(@ratings.map(&:value).sum / @ratings.count)
                end
            end

            context "Ratings doesn't exists" do
                before { get "/api/v1/ratings/#{@store.google_place_id}" }

                it { expect(response).to have_http_status(200) }

                it "Returns the rating empty" do
                    expect(JSON.parse(response.body)['ratings']).to be_empty
                end

                it "Returns the count equal 0" do
                    expect(JSON.parse(response.body)['ratings_count']).to eql(0)
                end
            end 
        end

        context "Store doesn't exists" do
            it "Returns status 404" do
                get "/api/v1/ratings/0000"
                
                expect(response).to have_http_status(404)
            end
        end        
    end

    describe "POST /ratings" do
        it "Create rating and store" do
            post "/api/v1/ratings", params: {
                                        store: {
                                            latitude: FFaker::Random.rand(1..999999),
                                            longitude: FFaker::Random.rand(1..999999),
                                            name: FFaker::Name.name,
                                            address: FFaker::AddressBR.full_address,
                                            google_place_id: FFaker::Lorem.characters
                                        }, 
                                        rating: {
                                            value: FFaker::Random.rand(1..5), 
                                            opinion: FFaker::Lorem.paragraph, 
                                            user_name: FFaker::Name.name
                                        }
                                    }
                                            
            expect(response).to have_http_status(200)
        end
    end
end
```

13 - E dentro do 'requests/stores_spec.rb', cole o seguinte código:

```
require 'rails_helper'

RSpec.describe "Stores", type: :request do
    describe "GET /stores" do
        before do
            (10).times do
                @store = FactoryBot.create(:store)
                @rating = FactoryBot.create(:rating, store_id: @store.id)
            end
        end

        context "Stores exists" do
            before do 
                get "/api/v1/stores", params: {latitude: -21.7412678, longitude: -41.3549968}
            end
            
            it { expect(response).to have_http_status(200) }
            
            it "Return stores near of user" do
                expect(JSON.parse(response.body).count).to be > 0
            end

            it "Verify if is ordered by rating average" do
                JSON.parse(response.body).each_with_index do |store, index|
                    if index > 0
                        expect(@last_store["ratings_average"]).to be >= store["ratings_average"]
                    end

                    @last_store = store
                end
            end
        end

        context "Stores don't exist" do
            before do 
                get "/api/v1/stores", params: {latitude: nil, longitude: nil}
            end

            it { expect(response).to have_http_status(200) }

            it "Returns an empty array" do
                expect(JSON.parse(response.body)).to eq([])
            end
        end
    end

    describe "GET /stores/:id" do
        it "Returns the correct store" do
            store = FactoryBot.create(:store)

            get "/api/v1/stores/#{store.id}"
            expect(response.body).to include(store.name, store.address)
        end
    end
end
```


### Criando nossos Models

1 - Adicione o seguinte código em seu gemfile:

```
# Gem to use PostGis
gem 'activerecord-postgis-adapter'
```

2 - Rode um bundle install.

3 - Crie o model rating com o seguinte comando:

```
rails g model Rating belongs_to:store value:integer opinion:string user_name:string
```

4 - Agora crie o model Rating com o seguinte comando:
```
rails g model Store
```

5 - Dentro da migration de Store, gerada, cole o seguinte código:
```
class CreateStores < ActiveRecord::Migration[5.2]
  def change
    create_table :stores do |t|
      t.st_point :lonlat, geographic: true
      t.string :name
      t.string :address
      t.string :google_place_id
      t.timestamps
    end

    add_index :stores, :lonlat, using: :gist
  end
end
```

6 - Dentro do model Rating.rb, cole o seguinte código:

```
class Rating < ApplicationRecord
    validates_presence_of :value, :opinion, :user_name
end
```

7 - E substitua o código do model Store.rb por:

```
class Store < ApplicationRecord
    has_many :ratings

    validates_presence_of :lonlat, :name
    
    scope :within, -> (latitude, longitude, distance_in_mile = 1800) {
        where(%{
            ST_Distance(lonlat, 'POINT(%f %f)') < %d
        } % [longitude, latitude, distance_in_mile * 1609.34])
    }

    def ratings_average
        (self.ratings.sum(:value) / self.ratings.count).to_i if ratings.count > 0
    end
end
```

(O Escopo 'within' localizará nossas Stores mais próximas. É usado pelo PostGis pelo link:
https://medium.com/@hin556/location-based-searching-in-rails-5-part-2-using-postgis-extension-7ab2d34b9885).


### Criando os endpoints

1 - Para iniciarmos, vamos gerar nossos controllers ratings_controller.rb e stores_controller.rb com os comandos:

```
rails g controller api/v1/stores
rails g controller api/v1/ratings
rails g controller api/v1/google_stores
```

2 - Agora no nosso config/routes.rb, vamos pré instanciar nossas rotas substituindo pelo seguinte código:

```
Rails.application.routes.draw do

  namespace :api do
    namespace :v1 do
      resources :ratings, :defaults => { :format => 'json' }
      resources :stores, :defaults => { :format => 'json' }
      resources :google_stores, :defaults => { :format => 'json' }
    end
  end
  
end
```

3 - Primeiro, coloque os seguintes métodos no controller ratings_controller.rb:

```
before_action :set_store, only: [:show]

def show
end

private

def set_store
    @store = Store.find_by(google_place_id: params[:id])
end
```

4 - Como instanciamos nossas rotas para o padrão de resposta Json, crie as 
pastas /app/views/api/v1/ratings e /app/views/api/v1/stores.

5 - Agora crie a view api/v1/ratings/show.json.jbuilder.


6 - Dentro dessa view, cole o seguinte conteúdo (As views Json.jbuilder personalizam nossa resposta json).
```
json.ratings @store.ratings do |rating|
    json.value rating.value
    json.opinion rating.opinion
    json.user_name rating.user_name
    json.date rating.created_at.strftime("%d/%m/%Y")
end

json.ratings_count @store.ratings.count
json.ratings_average @store.ratings.sum(:value) / @store.ratings.count
```

7 - Para testar, rode o console com o rails c e execute os comandos abaixo:

```
Store.create!(name: "Coffee 1", lonlat:"POINT(#{114.2219923} #{22.3129115})")
Store.create!(name: "Coffee 2 (too far)", lonlat:"POINT(#{114.5019993} #{22.9429125})")
```

8 - Executando o comando abaixo, o console mostrará as Stores cadastradas em um raio de 2000 milhas de distância:

```
Store.within(-21.7361752, -41.3498393, 2000)
```


9 - Agora vamos criar o método "create" do nosso controller ratings_controller.rb.

10 - Cole o seguinte método abaixo do método "show":

```
    def show
    end

    ...

    def create
        ActiveRecord::Base.transaction do
            create_store
            create_rating

            render json: {status: 200, message: 'Avaliação enviada com sucesso!'}
        end
    end

    ...

    private
```

11 - Agora, junto aos métodos privados, cole os seguintes métodos:

```
  ...

  private

   def create_rating
        @rating = Rating.new(ratings_params)

        @rating.store_id = @store.id

        if !@rating.save!
            render json: {status: 500, message: 'Não foi possível criar avaliação!'}
        end
    end

    def create_store
        @store = Store.find_or_create_by(
            lonlat: "POINT(#{params[:store][:latitude].to_f} #{params[:store][:longitude].to_f})",
            name: params[:store][:name],
            address: params[:store][:address],
            google_place_id: params[:store][:place_id]
        )

        if !@store
            render json: {status: 500, message: 'Não foi possível criar a Store!'}
        end
    end

    def ratings_params
        params.require(:rating).permit(:value, :opinion, :user_name)
    end

    ...
```

12 - Esses métodos servem para, assim que uma avaliação for realizada em uma loja, o endpoint cria a Store no BD ou
acha essa Store caso a mesma já tenha sido avaliada, criando também sua respectiva avaliação.

13 - Agora vamos criar o controller api/v1/stores_controller.rb.

14 - Nele, terão os métodos de index e show, somente. Cole o código abaixo nele:

```
class Api::V1::StoresController < ApplicationController
    before_action :set_store, only: [:show]

    def index
        @stores = Store.within(params[:latitude].to_f, params[:longitude].to_f)
    end

    def show
    end

    private

    def set_store
        @store = Store.find(params[:id])
    end
end
```

15 - Com esses endpoints criados, vamos às views.

16 - Crie três jsons:
api/v1/stores/_store_essential.json.jbuilder (Arquivos básicos e repetidos pelo Json da Store)
api/v1/stores/index.json.jbuilder
api/v1/stores/show.json.jbuilder

17 - No json _store_essential.json.jbuilder, cole o seguinte código:

```
json.id store.id
json.lonlat store.lonlat
json.name store.name
json.address store.address
```

18 - Com os códigos essenciais setados, vamos ao api/v1/stores/index.json.jbuilder. Cole o código abaixo no mesmo:

```
json.array! @stores do |store|
    json.partial! 'store_essential', store: store
    json.ratings_count store.ratings.count
    json.ratings_average store.ratings_average
end
```

19 - E no json api/v1/stores/show.json.jbuilder, cole o seguinte código:

```
json.partial! 'store_essential', store: @store
json.ratings @store.ratings
```

(Perceba que estamos renderizando a partial store_essential nos dois arquivos)

### Criando nossos services

1 - Crie uma pasta app/services, e nela crie os arquivos all_coffee_services.rb e o show_coffee_details_service.rb.

Por eles faremos nossa chamada API para a api do google.

2 - Inicie o service all_coffees_service.rb com o seguinte código:

```
require 'rest-client'
require 'json'

class AllCoffeesService
    def initialize()
    end
  
    def call
        begin
      
        rescue RestClient::ExceptionWithResponse => e
            e.response
        end
    end
end
```

3 - Agora vamos prepará-lo para receber os parâmetros de latitude e longitude ao ser instanciado. Deixe seu método "initialize" do seguinte modo:

```
def initialize(latitude, longitude)
    @latitude = latitude
    @longitude = longitude
end
```

4 - Agora no método "call", deixe-o com a seguinte aparência:
```
def call
        begin
            base_url = "https://maps.googleapis.com/maps/api/place/textsearch/json?query=coffee+shop&location=-#{@latitude},#{@longitude}&radius=5000&key=SUA_GOOGLE_API_KEY"
            response = RestClient.get base_url
            value = JSON.parse(response.body)
      
        rescue RestClient::ExceptionWithResponse => e
            e.response
        end
    end
```

5 - Em nosso controller, google_stores_controller.rb, anteriormente gerado, vamos colocar a nossa chamada API pelo service. Coloque o seguinte código:
```
class Api::V1::GoogleStoresController < ApplicationController
    def index
        render json: AllCoffeesService.new(params[:latitude].to_f, params[:longitude].to_f).call
    end
end
```

6 - Agora, no service show_coffee_details_service.rb, coloque o seguinte código:
```
require 'rest-client'
require 'json'

class ShowCoffeeDetailsService
    def initialize()
    end
  
    def call
        begin
      
        rescue RestClient::ExceptionWithResponse => e
            e.response
        end
    end
end
```

7 - Vamos prepará-lo para receber o nosso id do estabelecimento, vindo do google. Deixe o método "initialize" da seguinte forma:

```
def initialize(place_id)
    @place_id = place_id
end
```

8 - Agora vamos deixar o método "call" preparado para receber essa api:
```
def call
    begin
        base_url = "https://maps.googleapis.com/maps/api/place/details/json?place_id=#{@place_id}&key=SUA_GOOGLE_API_KEY"
        response = RestClient.get base_url
        value = JSON.parse(response.body)
    
    rescue RestClient::ExceptionWithResponse => e
        e.response
    end
end
```

9 - Para finalizar, adicione mais um método no controller google_stores_controller.rb:
```
def show
    render json: ShowCoffeeDetailsService.new(params[:id]).call
end
```

10 - O controller ficará da seguinte forma:
```
class Api::V1::GoogleStoresController < ApplicationController
    def index
        render json: AllCoffeesService.new(params[:latitude].to_f, params[:longitude].to_f).call
    end

    def show
        render json: ShowCoffeeDetailsService.new(params[:id]).call
    end
end
```
### Habilitando o CORS no nosso projeto

1 - Adicione a seguinte gem em seu Gemfile:

gem 'rack-cors'

2 - Rode o blunde em seu terminal.

3 - Crie ou adicione o seguinte código no arquivo /config/initializers/cors.rb:

```
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins '*'

    resource '*',
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head]
  end
end
```

E é isso!! API feita!
