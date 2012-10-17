class Loan < ActiveRecord::Base

  ## Macros ##

  resourcify

  state_machine :initial => :unapproved do

    event :approve do
      transition [:building, :rejected, :unapproved] => :approved, :if => :valid?
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

    event :reject do
      transition :unapproved => :rejected
    end

    state :approved do
      validates_presence_of :approver
    end

    state :checked_in do
      validates_presence_of :in_assistant
      validates :in_at, :presence => true
    end

    state :checked_out do
      validates_presence_of :out_assistant
      validates :out_at, :presence => true
      validate :validate_client_signed_all_covenants
    end

    state :unapproved do
      before_save :try_auto_approve
      validate    :validate_open_on_starts_at
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
  validates_presence_of :location # not persisted, but it makes the controller/view simpler
  validates :starts_at,  :presence => true
  validates :ends_at,    :presence => true
  validate  :validate_client_has_permission
  validate  :validate_kit_is_available
  validate  :validate_kit_is_checkoutable
  validate  :validate_open_on_ends_at


  ## Virtual Attributes ##

  attr_writer :component_model, :component_model_id, :location_id


  ## Instance Methods ##

=begin
  def adjust_starts_at
    set_to_location_open_at!
  end

  def adjust_ends_at
    set_to_location_close_at!
  end
=end

  def available_checkoutable_kits
    return nil if component_model.nil?
    component_model.available_checkoutable_kits(starts_at, ends_at, location)
  end

  # this should either be set via the component_model virtual
  # attribute, or retrieved from the kit's attributes
  def component_model
    return nil unless kit.nil?
    @component_model ||= begin
      ComponentModel.find(component_model_id) if component_model_id
    end
  end

  def component_model_id
    @component_model_id ||= component_model.try(:id)
  end

  # this should either be set via the attr_writer :location, or
  # retrieved from the kit's attributes
  def location
    @location ||= self.try(:kit).try(:location)
  end

  def location=(val)
    if val.is_a? String
      @location = Location.find(val.to_i)
    elsif val.is_a? Fixnum
      @location = Location.find(val)
    elsif vali.is_a? Location
      @location = val
    else
      raise "Expected a string, fixnum, or location"
    end
  end

  def location_id
    @location_id ||= @location.try(:id)
  end

  # this should be retrieved from the component model's attributes,
  # which is, in turn, derived from the kit, or the component model
  # virtual attribute
  def locations
    if kit
      return [kit.location]
    else
      component_model.checkout_locations
    end
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

  def within_default_length?
    default        = AppConfig.instance.default_checkout_length

    # if there's no default length, then go, go, go!
    return true unless default

    expected_time  = (starts_at + default.days).to_time
    next_date_open = location.next_date_open(expected_time)

    return (ends_at.to_date <= next_date_open)
  end

  private

  # this should only be called after validations have run
  def try_auto_approve
    if within_default_length?
      # the default scope excludes "system"
      self.approver = User.unscoped.find_by_username("system")
      approve
    end
  end

  def validate_client_has_permission
    unless kit.can_be_loaned_to? client
      errors.add(:client, "does not have permission to check out this kit.")
    end
  end

  def validate_client_signed_all_covenants
    unless client.signed_all_covenants?
      errors.add(:client, "has not signed all covenants.")
    end
  end

  def validate_kit_is_available
    unless kit && !kit.loaned_between?(starts_at, ends_at, [self])
      errors.add(:kit, "is already loaned out for some (or all) of the reqested dates.")
    end
  end

  def validate_kit_is_checkoutable
    unless kit && kit.checkoutable?
      errors.add(:kit, "is not checkoutable. Choose another kit.")
    end
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
