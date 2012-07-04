class ModelTweaks < ActiveRecord::Migration
  def up
    change_column_default :kits, :checkoutable, false
  end

  def down
  end
end
