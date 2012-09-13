class CreateCovenantSignatures < ActiveRecord::Migration
  def change
    create_table :covenant_signatures do |t|
      t.references :user
      t.references :covenant
      t.timestamps
    end
  end
end
