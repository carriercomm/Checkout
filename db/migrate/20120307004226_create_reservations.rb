class CreateReservations < ActiveRecord::Migration
  def change
    create_table :reservations do |t|
      t.references :kit
      t.datetime :start_at
      t.datetime :end_at
      t.datetime :out_at
      t.datetime :in_at
      t.boolean :late
      t.integer :client_id
      t.text    :request_note
      t.integer :approver_id
      t.text    :approval_note
      t.integer :out_assistant_id
      t.integer :in_assistant_id
      t.timestamps
    end
    add_index :reservations, :kit_id                        # find the kit for the reservation
    add_index :reservations, :client_id                     # find people
    add_index :reservations, :approver_id                   # find people
    add_index :reservations, :out_assistant_id              # find people
    add_index :reservations, :in_assistant_id               # find people
    add_index :reservations, [:start_at, :out_at]           # find pending reservations
    add_index :reservations, :end_at                        # find overdue reservations
    add_index :reservations, [:end_at, :in_at, :late]       # calculate late/grace days
  end
end
