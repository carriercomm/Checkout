class CreateBusinessHourExceptions < ActiveRecord::Migration
  def change
    create_table :business_hour_exceptions do |t|
      t.references :location, :null => false
      t.date :date_closed, :null => false

      t.timestamps
    end
    add_index :business_hour_exceptions, :location_id
  end
end
