class CreateBudgets < ActiveRecord::Migration
  def change
    create_table :budgets do |t|
      t.string  :number
      t.string  :name
      t.date    :date_start
      t.date    :date_end

      t.timestamps
    end
  end
end
