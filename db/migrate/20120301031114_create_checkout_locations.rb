class CreateCheckoutLocations < ActiveRecord::Migration
  def change
    create_table :checkout_locations do |t|
      t.string :name
      t.string :room

      t.timestamps
    end
  end
end
