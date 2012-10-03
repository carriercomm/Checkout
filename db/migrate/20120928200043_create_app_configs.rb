class CreateAppConfigs < ActiveRecord::Migration
  def change
    create_table :app_configs do |t|
      t.integer :default_checkout_length
      t.timestamps
    end
  end
end
