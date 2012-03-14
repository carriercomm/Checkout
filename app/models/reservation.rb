class Reservation < ActiveRecord::Base

  belongs_to :kit
  belongs_to :client,        :class_name => "User"
  belongs_to :approver,      :class_name => "User"
  belongs_to :out_assistant, :class_name => "User"
  belongs_to :in_assistant,  :class_name => "User"

  validates :client_id, :presence => true
  validates :kit_id,    :presence => true
  validates :start_at,  :presence => true
  validates :end_at,    :presence => true

  attr_accessible :client_id, :kit_id, :start_at, :end_at

  before_validation :adjust_start_at
  before_validation :adjust_end_at

  def adjust_start_at
    set_to_location_open_at!
  end

  def adjust_end_at
    set_to_location_close_at!
  end

  # TODO: deal with UTC parsing problems
  def set_to_location_open_at!
    # get the first opening time on the day
    opens_at = kit.location.opens_at(self.start_at)

    # figure out what the opening time's offset is from midnight
    offset = opens_at.seconds_since_midnight

    # set start_at to the same offset
    self.start_at = self.start_at.beginning_of_day + offset
  end

  def set_to_location_close_at!
    # get the last closing time on the day
    closes_at = kit.location.closes_at(self.end_at)

    # figure out what the closing time's offset is from midnight
    offset = closes_at.seconds_since_midnight

    # set end_at to the same offset
    self.end_at = self.end_at.beginning_of_day + offset
  end


end
