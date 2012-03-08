class CreateBusinessHours < ActiveRecord::Migration
  def change
    create_table :business_hours do |t|
      t.string :day
      t.time :open
      t.time :close

      t.timestamps
    end
  end
end
