class MoveBudgets < ActiveRecord::Migration
  def up
    Checkout::Budget.connection.select_rows('select budget_number, budget_name from budgets').each do |row|
      Checkout::Budget.create!(:number => row.first, :name => row.last)
    end
  end

  def down
    Checkout::Budget.delete_all
  end
end
