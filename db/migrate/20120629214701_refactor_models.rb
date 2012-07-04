class RefactorModels < ActiveRecord::Migration
  def change
    # change the kits model
    add_column    :kits, :model_id, :integer
    add_column    :kits, :budget_id, :integer
    add_column    :kits, :cost, :decimal
    add_column    :kits, :insured, :boolean, :default => false
    remove_column :kits, :name

    # change the parts/components model
    rename_table  :parts, :components
    remove_column :components, :cost
    remove_column :components, :insured
    remove_column :components, :budget_id
    remove_column :components, :model_id
    add_column    :components, :description, :text

    rename_column :asset_tags, :part_id, :component_id
  end

end
