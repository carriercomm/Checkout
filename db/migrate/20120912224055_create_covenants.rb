class CreateCovenants < ActiveRecord::Migration
  def change
    create_table :covenants do |t|
      t.string :name, :null => false
      t.text :description
      t.timestamps
    end
  end
end
