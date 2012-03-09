class CreateBusinessHours < ActiveRecord::Migration
  def change
    create_table :business_hours do |t|
      t.references :location, :null => false
      t.string  :day, :null => false
      t.string  :open
      t.string  :close

      t.timestamps
    end

    add_index :business_hours, :location_id

  end
end
