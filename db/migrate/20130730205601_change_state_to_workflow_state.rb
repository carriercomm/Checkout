class ChangeStateToWorkflowState < ActiveRecord::Migration
  def change
    rename_column :loans, :state, :workflow_state
  end
end
