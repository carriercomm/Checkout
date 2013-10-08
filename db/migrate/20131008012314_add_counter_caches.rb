class AddCounterCaches < ActiveRecord::Migration
  def up
    Brand.reset_column_information
    ComponentModel.reset_column_information

    add_column :brands, :component_models_count, :integer, :default => 0
    add_column :component_models, :components_count, :integer, :default => 0

    Brand.reset_column_information
    Brand.all.each do |b|
      b.update_attribute :component_models_count, b.component_models.count
    end

    ComponentModel.reset_column_information
    ComponentModel.all.each do |cm|
      cm.update_attribute :components_count, cm.components.count
    end
  end

  def down
    remove_column :brands, :component_models_count
    remove_column :component_models, :components_count
  end
end
