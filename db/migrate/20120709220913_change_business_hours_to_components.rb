class ChangeBusinessHoursToComponents < ActiveRecord::Migration
  def change
    remove_column :business_hours, :open_at
    remove_column :business_hours, :closed_at
    add_column    :business_hours, :open_day,      :string, :null => false
    add_column    :business_hours, :open_hour,     :string, :null => false
    add_column    :business_hours, :open_minute,   :string, :null => false
    add_column    :business_hours, :close_day,    :string, :null => false
    add_column    :business_hours, :close_hour,   :string, :null => false
    add_column    :business_hours, :close_minute, :string, :null => false
  end
end
