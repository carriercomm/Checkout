class CreateCheckoutBudgets < ActiveRecord::Migration
  def change
    create_table :checkout_budgets do |t|
      t.string :number
      t.string :name

      t.timestamps
    end
  end
end
