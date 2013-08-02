class RenameAssistantToAttendant < ActiveRecord::Migration
  def change
    rename_column :loans, :in_assistant_id,  :in_attendant_id
    rename_column :loans, :out_assistant_id, :out_attendant_id
  end
end
