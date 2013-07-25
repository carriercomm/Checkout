class Loan < ActiveRecord::Base

  ## Macros ##

  resourcify

  state_machine :initial => :pending do

    after_failure do |loan, transition|
      logger.debug "loan #{loan} failed to transition on #{transition.event}"
      logger.debug loan.inspect
      logger.debug transition.inspect
      logger.debug loan.errors.inspect
    end

    before_transition :any => :pending do |loan, transition|
      logger.debug "--- transitioning to pending"
      loan.write_attribute(:ends_at, nil)
      loan.write_attribute(:approver_id, nil)
    end

    # before_transition :any => :pending do |loan, transition|
    #   loan.auto_approve!
    # end

    event :approve do
      transition [:rejected, :pending] => :approved, :if => :valid?
    end

    event :cancel do
      transition [:rejected, :pending, :approved] => :canceled
    end

    event :check_out do
      transition :approved => :checked_out
    end

    event :check_in do
      transition :checked_out => :checked_in
    end

    event :reject do
      transition :pending => :rejected
    end

    event :unapprove do
      transition [:approved, :pending] => :pending
    end

    state :approved do
      # TODO: verify this check_approval callback doesn't need to be on other states
      before_save :check_approval
      validates :approver_id, :presence => true
    end

    state :checked_in do
      validates_presence_of :in_assistant
      validates :in_at, :presence => true
    end

    state :checked_out do
      validates_presence_of :out_assistant
      validates :out_at, :presence => true
      validate :validate_client_has_proper_training
      validate :validate_client_signed_all_covenants
    end

    state :pending do
      before_validation :autofill_ends_at!
      after_save        :auto_approve!
      validate          :validate_open_on_starts_at
    end

  end

  ## Associations ##

  # Ensure User is not scoped
  def approver
    User.unscoped { super }
  end

  belongs_to :kit,               :inverse_of => :loans
  belongs_to :client,            :inverse_of => :loans,       :class_name => "User"
  belongs_to :approver,          :inverse_of => :approvals,   :class_name => "User"
  belongs_to :out_assistant,     :inverse_of => :out_assists, :class_name => "User"
  belongs_to :in_assistant,      :inverse_of => :in_assists,  :class_name => "User"
  has_many   :inventory_records, :inverse_of => :loan

  ## Callbacks ##

  #before_validation :

  ## Validations ##

  # NOTE: additional state-dependent validations defined in the state machine above
  validates_presence_of :client_id
  validates_presence_of :client
  validates_presence_of :kit
  validates_presence_of :location # not persisted, but it makes the controller/view simpler
  validates :starts_at, :presence => true
  validates :ends_at,   :presence => true
  validate  :validate_client_has_permission,   :unless => :importing_legacy_records?
  validate  :validate_client_is_not_disabled,  :unless => :importing_legacy_records?
  validate  :validate_client_is_not_suspended, :unless => :importing_legacy_records?
  validate  :validate_kit_available,           :unless => :importing_legacy_records?
  validate  :validate_kit_circulating,         :unless => :importing_legacy_records?
  validate  :validate_open_on_ends_at,         :unless => :importing_legacy_records?
  validate  :validate_start_at_before_ends_at, :unless => :importing_legacy_records?

  ## Virtual Attributes ##

  attr_writer   :component_model, :component_model_id, :location_id
  attr_accessor :importing

  ## Instance Methods ##

  # this should only be called after validations have run
  def auto_approve!
    if pending? && within_default_length?
      logger.debug "---- AUTO APPROVING"
      self.approver = User.system_user
      approve
    end
    nil
  end

  def autofill_ends_at!
    self.ends_at = default_return_date
  end

  def available_circulating_kits
    return nil if component_model.nil?
    component_model.available_circulating_kits(starts_at, ends_at, location)
  end

  # if this loan was auto_approved, make sure the checkout duration is
  # still valid - rollback the state if necessary
  def check_approval
    if ((self.approver.nil? || self.approver == User.system_user) && !within_default_length?)
      unapprove
    end

    true
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

  def default_return_date
    default        = AppConfig.instance.default_checkout_length
    expected_time  = (self.starts_at + default.days).to_time.getlocal
    location.next_time_open(expected_time)
  end

  def importing_legacy_records?
    importing && (ends_at < Time.zone.now)
  end

  def kit_available?
    kit && kit.available?(starts_at, ends_at, self)
  end

  def kit_circulating?
    kit && kit.circulating?
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

  def prefill_checkout
    self.starts_at = Date.today unless self.starts_at
    self.ends_at   = kit.default_return_date(starts_at) unless self.ends_at
    self.out_at    = Time.zone.now
  end

  def starts_at=(time)
    if time.is_a? String
      write_attribute(:starts_at, Time.zone.parse(time))
    else
      write_attribute(:starts_at, time.to_time)
    end

    if !new_record? && self.starts_at_changed?
      unapprove
    end
    self
  end

  def within_default_length?
    raise "Start and end dates must be defined" unless starts_at && ends_at
    return (ends_at <= default_return_date)
  end

private

  def validate_client_is_not_disabled
    if client.disabled?
      errors.add(:client, "is disabled.")
    end
  end

  def validate_client_is_not_suspended
    if client.suspended?(self.starts_at)
      errors.add(:client, "is suspended until #{ UserDecorator.decorate(client).suspended_until }.")
    end
  end

  def validate_client_has_permission
    unless kit.permissions_include? client
      errors.add(:client, "does not have permission to check out this kit.")
    end
  end

  def validate_client_has_proper_training
    if kit.training_required?
      errors.add(:client, "does not have proper training for this kit.")
    end
  end

  def validate_client_signed_all_covenants
    unless client.signed_all_covenants?
      errors.add(:client, "has not signed all covenants.")
    end
  end

  def validate_kit_available
    unless kit_available?
      errors.add(:starts_at, "kit is already loaned out for some (or all) of the reqested dates.")
    end
  end

  def validate_kit_circulating
    unless kit_circulating?
      errors.add(:kit, "is not circulating. Choose another kit.")
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

  def validate_start_at_before_ends_at
    unless starts_at < ends_at
      errors.add(:starts_at, "must come before the return date")
    end
  end

end
