class ChangeCheckoutableToCirculating < ActiveRecord::Migration
  def change
    rename_column "kits", "checkoutable", "circulating"
    rename_index "kits", "index_kits_on_checkoutable", "index_kits_on_circulating"
  end
end
