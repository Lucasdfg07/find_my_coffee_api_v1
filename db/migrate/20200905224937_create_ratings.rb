class CreateRatings < ActiveRecord::Migration[5.2]
  def change
    create_table :ratings do |t|
      t.belongs_to :store
      t.integer :value
      t.string :opinion
      t.string :user_name
      t.timestamps
    end
  end
end
