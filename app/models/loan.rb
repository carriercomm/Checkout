class Loan < ActiveRecord::Base

  ## Macros ##

  resourcify
  include Workflow

  workflow do
    # pending has to come first so it will be the starting state by convention
    state :pending do
      event :approve,   :transitions_to => :approved
      event :cancel,    :transitions_to => :canceled
      event :decline,    :transitions_to => :declined
    end

    state :approved do
      event :cancel,    :transitions_to => :canceled
      event :check_out, :transitions_to => :checked_out
      event :unapprove, :transitions_to => :pending
    end

    state :canceled
    state :checked_in

    state :checked_out do
      event :check_in,  :transitions_to => :checked_in
      event :mark_lost, :transitions_to => :lost
    end

    state :declined do
      event :resubmit,  :transitions_to => :pending
    end

    state :lost do
      event :check_in,  :transitions_to => :checked_in
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
  belongs_to :out_attendant,     :inverse_of => :out_assists, :class_name => "User"
  belongs_to :in_attendant,      :inverse_of => :in_assists,  :class_name => "User"
  has_many   :inventory_records, :inverse_of => :loan

  ## Validations ##

  validates :approver,          :associated => true,    :unless => [:pending?, :declined, :checked_in?]
  validates :approver_id,       :presence   => true,    :unless => [:pending?, :declined, :checked_in?]
  validates :client,            :associated => true
  validates :client_id,         :presence   => true
  validates :ends_at,           :presence   => true,    :unless => [:pending?, :checked_in?]
  validates :in_at,             :presence   => true,    :if     => :checked_in?
  validates :in_attendant,      :associated => true,    :if     => :checked_in?
  validates :in_attendant_id,   :presence   => true,    :if     => :checked_in?
  validates :kit,               :associated => true
  validates :kit_id,            :presence   => true
  validates :out_at,            :presence   => true,    :if     => :checked_out?
  validates :out_attendant,     :associated => true,    :if     => :checked_out?
  validates :out_attendant_id,  :presence   => true,    :if     => :checked_out?
  validates :starts_at,         :presence   => true,    :unless => :checked_in?
  validate  :validate_client_has_permission,            :unless => :checked_in?
  validate  :validate_client_has_proper_training,       :if     => :checked_out?
  validate  :validate_client_is_not_disabled,           :unless => :checked_in?
  validate  :validate_client_is_not_suspended,          :unless => :checked_in?
  validate  :validate_client_signed_all_covenants,      :if     => :checked_out?
  validate  :validate_kit_available,                    :unless => :checked_in?
  validate  :validate_kit_circulating,                  :unless => :checked_in?
  validate  :validate_open_on_starts_at,                :if     => :pending?
  validate  :validate_open_on_ends_at,                  :unless => [:pending?, :checked_in?]
  validate  :validate_in_attendant_is_attendent,        :if     => :checked_in?
  validate  :validate_in_attendant_is_not_client,       :if     => :checked_in?
  validate  :validate_out_attendant_is_attendent,       :if     => :checked_out?
  validate  :validate_out_attendant_is_not_client,      :if     => :checked_out?
  validate  :validate_start_at_before_ends_at,          :unless => [:pending?, :checked_in?]

  validates_presence_of :location # not persisted, but it makes the controller/view simpler

  ## Virtual Attributes ##

  attr_writer   :component_model, :component_model_id, :location_id
  attr_accessor :importing

  ## Class Methods ##

  def self.build(params)
    loan = self.new(params)
    if loan.kit
      loan.starts_at = loan.kit.location.next_time_open
    else
      loan.starts_at = Date.today
    end
    loan
  end

  ## Instance Methods ##

  def autofill_ends_at!
    write_attribute(:ends_at, default_return_date)
    write_attribute(:autofilled_ends_at, true)
  end

  def autofilled_ends_at?
    autofilled_ends_at
  end

  def available_circulating_kits
    if component_model
      return component_model.available_circulating_kits(starts_at, ends_at, location)
    elsif kit
      return kit.component_model.available_circulating_kits(starts_at, ends_at, location)
    else
      return nil
    end
  end

  # if this loan was auto_approved, make sure the checkout duration is
  # still valid - rollback the state if necessary
  def ready_for_approval?
    if !approver.nil? && within_default_length?
      return true
    else
      return false
    end
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
    default = Settings.default_checkout_duration
    time    = (self.starts_at + default.days)
    time    = Time.local(time.year, time.month, time.day, time.hour, time.min, time.sec)
    location.next_time_open(time).to_datetime
  end

  def ends_at=(time)
    if time.is_a? String
      write_attribute(:starts_at, Time.zone.parse(time).to_datetime)
    else
      write_attribute(:starts_at, time.to_datetime)
    end

    if !pending? && ends_at_changed?
      unapprove!
    end

    ends_at
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

  def on_pending_entry(state, event, args=nil)
    # puts "state: " + state.inspect
    # puts "event: " + event.inspect
    # puts "args: " + args.inspect

    if autofilled_ends_at
      write_attribute(:ends_at, nil)
      write_attribute(:autofilled_ends_at, false)
    end

    # clear the approver
    write_attribute(:approver_id, nil)
  end

  def open_on_ends_at?
    return false if kit.nil? || kit.location.nil? || self.ends_at.nil?
    return kit.location.open_on?(self.ends_at)
  end

  def open_on_starts_at?
    return false if kit.nil? || kit.location.nil? || self.ends_at.nil?
    return kit.location.open_on?(self.starts_at)
  end

  # Overriding Workflow's default active_record behavior:
  # We might move through several states in a given controller action,
  # so avoid the database roundtrip. Call save explicitly to persist.
  def persist_workflow_state(new_state)
    write_attribute self.class.workflow_column, new_state.to_s
  end

  def starts_at=(time)
    if time.is_a? String
      write_attribute(:starts_at, Time.zone.parse(time).to_datetime)
    else
      write_attribute(:starts_at, time.to_datetime)
    end

    if starts_at_changed?
      if (ends_at.nil? || (ends_at && autofilled_ends_at)) && !ends_at_changed? && location
        ends_at = default_return_date
      end

      if !pending? && starts_at_changed?
        unapprove!
      end
    end

    starts_at
  end

  def try_automatic_approval
    autofill_ends_at! if ends_at.nil? || (ends_at && autofill_ends_at)

    if approver.nil? && within_default_length?
      write_attribute(:approver_id, User.system_user.id)
    end
    self
  end

  def within_default_length?
    raise "Start and end dates must be defined" unless starts_at && ends_at
    return (ends_at <= default_return_date)
  end

private

  # this is a callback which is invoked when approved! is called
  def approve
    try_automatic_approval
  end

  def check_out(out_attendant)
    self.out_attendant = out_attendant
    out_at = Time.zone.now.to_datetime
  end

  def validate_client_is_not_disabled
    if client && client.disabled?
      errors.add(:client, "is disabled.")
    end
  end

  def validate_client_is_not_suspended
    if client && starts_at && client.suspended?(starts_at)
      errors.add(:client, "is suspended until #{ UserDecorator.decorate(client).suspended_until }.")
    end
  end

  def validate_client_has_permission
    unless kit && client && kit.permissions_include?(client)
      errors.add(:client, "does not have permission to check out this kit.")
    end
  end

  def validate_client_has_proper_training
    if kit && kit.training_required?
      errors.add(:client, "does not have proper training for this kit.")
    end
  end

  def validate_client_signed_all_covenants
    unless client && client.signed_all_covenants?
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

  def validate_in_attendant_is_attendent
    unless in_attendant && in_attendant.attendent?
      errors.add(:in_attendant, "must be an attendant")
    end
  end

  def validate_in_attendant_is_not_client
    unless (in_attendant && (in_attendant != client)) || in_attendant.admin?
      errors.add(:in_attendant, "cannot check in items to themselves unless they are an admin")
    end
  end

  def validate_out_attendant_is_attendent
    unless out_attendant && out_attendant.attendent?
      errors.add(:out_attendant, "must be an attendant")
    end
  end

  def validate_out_attendant_is_not_client
    unless (out_attendant && (out_attendant != client)) || out_attendant.admin?
      errors.add(:out_attendant, "cannot check out items to themselves unless they are an admin")
    end
  end

  def validate_start_at_before_ends_at
    unless starts_at && ends_at && (starts_at < ends_at)
      errors.add(:starts_at, "must come before the return date")
    end
  end

end
