class AddAutofilledEndsAtToLoan < ActiveRecord::Migration
  def change
    add_column :loans, :autofilled_ends_at, :boolean, default: false
  end
end
