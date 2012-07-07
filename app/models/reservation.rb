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
  validate  :validate_open_on_end_at
  validate  :validate_open_on_start_at

  attr_accessible :client_id, :kit_id, :start_at, :end_at
  attr_writer :model

  #
  # FIXME: these before filters are setting the days to the wrong day
  #

  # before_save :adjust_start_at
  # before_save :adjust_end_at

  def adjust_start_at
    set_to_location_open_at!
  end

  def adjust_end_at
    set_to_location_close_at!
  end

  def location
    self.try(:kit).try(:location)
  end

  def open_on_end_at?
    return kit.location.open_on?(self.end_at)
  end

  def open_on_start_at?
    return kit.location.open_on?(self.start_at)
  end

  # set the start_at datetime to the time the location opens
  def set_to_location_open_at!
    # get the first opening time on the day
    self.start_at = kit.location.opens_at(self.start_at)
  end

  # set the end_at datetime to the time the location closes
  def set_to_location_close_at!
    self.end_at = kit.location.closes_at(self.end_at)
  end

  def validate_open_on_end_at
    unless open_on_end_at?
      errors.add(:end_at, "must be on a day with valid checkout hours")
    end
  end

  def validate_open_on_start_at
    unless open_on_start_at?
      errors.add(:start_at, "must be on a day with valid checkout hours")
    end
  end
end
