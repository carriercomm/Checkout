class CreateCheckoutMakers < ActiveRecord::Migration
  def change
    create_table :checkout_makers do |t|
      t.string :name

      t.timestamps
    end
  end
end
