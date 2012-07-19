class CreateBusinessDays < ActiveRecord::Migration
  def up

    drop_table :business_hours

    create_table :business_hours do |t|
      t.integer  :location_id,     :null => false
      t.integer  :open_hour,    :null => false
      t.integer  :open_minute,  :null => false
      t.integer  :close_hour,   :null => false
      t.integer  :close_minute, :null => false
      t.datetime :created_at,   :null => false
      t.datetime :updated_at,   :null => false
    end

    create_table :business_days do |t|
      t.integer :index, :null => false
      t.string :name, :null => false
      t.timestamps
    end

    create_table :business_days_business_hours do |t|
      t.references :business_day
      t.references :business_hour
    end

  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

end
