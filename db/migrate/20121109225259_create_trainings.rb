class CreateTrainings < ActiveRecord::Migration
  def change
    create_table :trainings do |t|
      t.references :component_model
      t.references :user

      t.timestamps
    end
    add_index :trainings, :component_model_id
    add_index :trainings, [:user_id, :component_model_id], :unique => true
  end
end
