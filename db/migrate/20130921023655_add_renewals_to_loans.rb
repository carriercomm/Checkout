class AddRenewalsToLoans < ActiveRecord::Migration
  def change
    add_column :loans, :renewals, :integer, default: 0, null: false
  end
end
