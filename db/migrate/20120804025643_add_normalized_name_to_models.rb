class AddNormalizedNameToModels < ActiveRecord::Migration
  def up
    add_column :brands,     :autocomplete, :string
    add_column :categories, :autocomplete, :string
    add_column :models,     :autocomplete, :string

    Brand.all.each    { |i| i.save! }
    Category.all.each { |i| i.save! }
    Model.all.each    { |i| i.save! }

    change_column_null :brands,     :autocomplete, false
    change_column_null :categories, :autocomplete, false
    change_column_null :models,     :autocomplete, false
  end

  def down
    remove_column :brands,     :autocomplete
    remove_column :categories, :autocomplete
    remove_column :models,     :autocomplete
  end

end
