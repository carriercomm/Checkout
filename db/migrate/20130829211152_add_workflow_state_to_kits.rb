class AddWorkflowStateToKits < ActiveRecord::Migration
  def change
    add_column :kits, :workflow_state, :string, null: false, default: "non_circulating"
    add_index  :kits, ["workflow_state"]

    Kit.circulating.each do |k|
      k.attributes["workflow_state"] = "circulating"
      k.save
    end

    Kit.non_circulating.each do |k|
      k.attributes["workflow_state"] = "non_circulating"
      k.save
    end

    Kit.tombstoned.each do |k|
      k.attributes["workflow_state"] = "deaccessioned"
      k.save
    end

    remove_column :kits, "tombstoned"
    remove_column :kits, "circulating"
    remove_column :kits, "insured"
  end
end
