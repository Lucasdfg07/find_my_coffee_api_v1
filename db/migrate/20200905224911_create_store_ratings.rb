class CreateStoreRatings < ActiveRecord::Migration[5.2]
  def change
    create_table :store_ratings do |t|

      t.timestamps
    end
  end
end
