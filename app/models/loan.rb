class Loan < ActiveRecord::Base

  ## Macros ##

  resourcify

  state_machine :initial => :unapproved do

    event :approve do
      transition [:rejected, :unapproved] => :approved, :if => :valid?
    end

    event :reject do
      transition :unapproved => :rejected
    end

    event :cancel do
      transition [:rejected, :unapproved, :approved] => :canceled
    end

    event :check_out do
      transition :approved => :checked_out
    end

    event :check_in do
      transition :checked_out => :checked_in
    end

    state :unapproved do
      validate  :validate_open_on_starts_at
    end

  end

  ## Associations ##

  belongs_to :kit,           :inverse_of => :loans
  belongs_to :client,        :inverse_of => :loans,       :class_name => "User"
  belongs_to :approver,      :inverse_of => :approvals,   :class_name => "User"
  belongs_to :out_assistant, :inverse_of => :out_assists, :class_name => "User"
  belongs_to :in_assistant,  :inverse_of => :in_assists,  :class_name => "User"


  ## Validations ##

  # NOTE: additional state-dependent validations defined in the state machine above

  validates_presence_of :client
  validates_presence_of :kit
  validates :starts_at,  :presence => true
  validates :ends_at,    :presence => true
  validate  :validate_open_on_ends_at


  ## Virtual Attributes ##

  attr_writer :model, :location


  ## Class Methods ##

  def self.default_checkout_length?
    @@default_checkout_length_set ||= (@@default_checkout_length ? true : false)
  end

  def self.default_checkout_length
    @@default_checkout_length ||= AppSettings.instance.default_checkout_length
  end


  ## Instance Methods ##

  def adjust_starts_at
    set_to_location_open_at!
  end

  def adjust_ends_at
    set_to_location_close_at!
  end

  def location
    @location ||= self.try(:kit).try(:location)
  end

  def open_on_ends_at?
    return false if kit.nil? || kit.location.nil? || self.ends_at.nil?
    return kit.location.open_on?(self.ends_at)
  end

  def open_on_starts_at?
    return false if kit.nil? || kit.location.nil? || self.ends_at.nil?
    return kit.location.open_on?(self.starts_at)
  end

  # set the starts_at datetime to the time the location opens
  def set_to_location_open_at!
    # get the first opening time on the day
    self.starts_at = kit.location.opens_at(self.starts_at)
  end

  # set the ends_at datetime to the time the location closes
  def set_to_location_close_at!
    self.ends_at = kit.location.closes_at(self.ends_at)
  end

  def validate_open_on_ends_at
    unless open_on_ends_at?
      errors.add(:ends_at, "must be on a day with valid checkout hours")
    end
  end

  def validate_open_on_starts_at
    unless open_on_starts_at?
      errors.add(:starts_at, "must be on a day with valid checkout hours")
    end
  end

end
