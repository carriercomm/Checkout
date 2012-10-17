class ChangeKitTombstonedDefault < ActiveRecord::Migration
  def up
    change_column_default(:kits, :tombstoned, false)
  end

  def down
    change_column_default(:kits, :tombstoned, nil)
  end
end
