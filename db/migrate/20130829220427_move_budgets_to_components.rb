class MoveBudgetsToComponents < ActiveRecord::Migration
  def up
    add_column :components, :budget_id, :integer

    Component.all.each do |c|
      c.budget_id = c.kit.attributes[:budget_id]
      c.save
    end

    remove_column :kits, :budget_id
  end

  def down

  end
end
