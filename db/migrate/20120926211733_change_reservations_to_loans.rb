class ChangeReservationsToLoans < ActiveRecord::Migration
  def up
    rename_table :reservations, :loans
    add_column :loans, :state, :string
  end

  def down
    drop_column :loans, :state
    rename_table :loans, :reservations
  end
end
