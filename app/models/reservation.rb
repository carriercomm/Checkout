class Reservation < ActiveRecord::Base

  belongs_to :kit
  belongs_to :client,        :class_name => "User"
  belongs_to :approver,      :class_name => "User"
  belongs_to :out_assistant, :class_name => "User"
  belongs_to :in_assistant,  :class_name => "User"

  validates :kit_id, :presence => true
  validates :start_at, :presence => true
  validates :end_at, :presence => true

end
