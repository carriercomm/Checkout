class CreateBusinessHours < ActiveRecord::Migration
  def change
    create_table :business_hours do |t|
      t.references :location, :null => false
      t.datetime  :open_at, :null => false
      t.datetime  :closed_at, :null => false

      t.timestamps
    end

    add_index :business_hours, :location_id

  end
end
