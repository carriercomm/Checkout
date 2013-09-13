class AddModelNumberToComponentModels < ActiveRecord::Migration
  def change
    add_column :component_models, :model_number, :string

    ComponentModel.all.each do |cm|
      cm.save
    end
  end
end
