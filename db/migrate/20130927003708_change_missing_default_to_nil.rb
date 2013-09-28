class ChangeMissingDefaultToNil < ActiveRecord::Migration
  def up
    change_column_default(:inventory_details, :missing, nil)
  end

  def down
    change_column_default(:inventory_details, :missing, false)
  end
end
