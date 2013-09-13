class Loan < ActiveRecord::Base
  class InvalidDateTimeFormatException < Exception; end

  ## Mixins ##

  include Workflow

  ## Macros ##

  resourcify

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

  # Ensure User is not scoped - we typically hide the "system" user,
  # but loan approvals are the main use for the "system" user
  def approver
    User.unscoped { super }
  end

  belongs_to :kit,                         :inverse_of => :loans
  belongs_to :client,                      :inverse_of => :loans,     :class_name => "User"
  belongs_to :approver,                    :inverse_of => :approvals, :class_name => "User"
  has_one    :check_out_inventory_record,  :inverse_of => :loan,      :dependent => :destroy
  has_one    :check_in_inventory_record,   :inverse_of => :loan,      :dependent => :destroy


  ## Validations ##

  validates :approver,                   :presence => true, :if     => [:approved?, :checked_out?, :lost?]
  validates :check_in_inventory_record,  :presence => true, :if     => :checked_in?
  validates :check_out_inventory_record, :presence => true, :if     => :checked_out?
  validates :client,                     :presence => true
  validates :ends_at,                    :presence => true, :if     => [:approved?, :checked_out?, :lost?]
  validates :in_at,                      :presence => true, :if     => :checked_in?
  validates :kit,                        :presence => true, :unless => :canceled?
  validates :out_at,                     :presence => true, :if     => :checked_out?
  validates :starts_at,                  :presence => true, :unless => [:checked_in?, :canceled?]


  # TODO: cannot change the client unless the loan is new
  validate  :validate_approver_has_approver_role,       :unless => [:pending?, :declined?, :checked_in?, :canceled?]
  validate  :validate_check_out_components_inventoried, :if     => :checked_out?
  validate  :validate_check_in_components_inventoried,  :if     => [:checked_in?, :lost?]
  validate  :validate_client_has_permission,            :unless => [:checked_in?, :canceled?]
  validate  :validate_client_has_proper_training,       :if     => [:checked_out?, :canceled?]
  validate  :validate_client_is_not_disabled,           :unless => [:checked_in?, :canceled?]
  validate  :validate_client_is_not_suspended,          :unless => [:checked_in?, :canceled?]
  validate  :validate_client_signed_all_covenants,      :if     => [:checked_out?, :canceled?]
  validate  :validate_kit_available,                    :unless => [:checked_in?, :canceled?]
  validate  :validate_kit_circulating,                  :unless => [:checked_in?, :canceled?]
  validate  :validate_open_on_starts_at,                :if     => :pending?
  validate  :validate_open_on_ends_at,                  :unless => [:pending?, :checked_in?, :canceled?]
  validate  :validate_start_at_before_ends_at,          :unless => [:pending?, :checked_in?, :canceled?]


  ## Virtual Attributes ##

  attr_accessor :component_model
  delegate      :location, :to => :kit


  ## Class Methods ##

  def self.build(params)
    loan = self.new(params)
    if loan.kit
      loan.starts_at = loan.location.next_datetime_open
    else
      loan.starts_at = Date.today.in_time_zone
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

  def build_check_in_inventory_record_with_inventory_details(options = {})
    missing = options.delete(:missing)
    build_check_in_inventory_record_without_inventory_details(options.merge(loan: self, kit: kit))
    unless kit.nil?
      check_in_inventory_record.initialize_inventory_details(missing)
    end
    check_in_inventory_record
  end

  alias_method_chain :build_check_in_inventory_record, :inventory_details

  def build_check_out_inventory_record_with_inventory_details(options = {})
    missing = options.delete(:missing)
    options.merge!(loan: self, kit: kit)
    build_check_out_inventory_record_without_inventory_details(options)
    unless kit.nil?
      check_out_inventory_record.initialize_inventory_details(missing)
    end
    check_out_inventory_record
  end

  alias_method_chain :build_check_out_inventory_record, :inventory_details

  def default_return_date
    return nil unless kit && kit.location && kit.location.business_hours.count > 0
    default  = Settings.default_check_out_duration
    datetime = self.starts_at + default.days
    nto      = location.next_datetime_open(datetime)
    if nto
      return nto
    else
      return datetime
    end
  end

  def ends_at=(datetime)
    datetime = convert_to_datetime(datetime)
    write_attribute(:ends_at, datetime)

    if !pending? && ends_at_changed?
      unapprove!
    end

    ends_at
  end

  def on_pending_entry(state, event, args=nil)
    if autofilled_ends_at
      write_attribute(:ends_at, nil)
      write_attribute(:autofilled_ends_at, false)
    end

    # clear the approver
    write_attribute(:approver_id, nil)
  end

  # Overriding Workflow's default active_record behavior:
  # We might move through several states in a given controller action,
  # so avoid the database roundtrip. Call save explicitly to persist.
  # TODO: make this method private (after import is done)
  def persist_workflow_state(new_state)
    write_attribute self.class.workflow_column, new_state.to_s
  end

  def starts_at=(datetime)
    datetime = convert_to_datetime(datetime)
    write_attribute(:starts_at, datetime)

    if starts_at_changed?
      if (ends_at.nil? || (ends_at && autofilled_ends_at)) && !ends_at_changed?
        ends_at = default_return_date
      end

      if !pending? && starts_at_changed?
        unapprove!
      end
    end

    starts_at
  end

  def try_automatic_approval
    autofill_ends_at! if ends_at.nil? || (ends_at && autofilled_ends_at)

    if approver.nil? && within_default_length?
      write_attribute(:approver_id, User.system_user.id)
    end
    self
  end

  def within_default_length?
    raise "Start and end dates must be defined" unless starts_at && ends_at
    (ends_at.to_datetime <= default_return_date.to_datetime)
  end

private

  # this is a callback which is invoked when approved! is called
  def approve
    try_automatic_approval
    halt "Loan not ready for approval" unless valid? && ready_for_approval?
  end

  def approver_has_approval_role?
    ensure_presence(approver)
    approver.approver?
  end

  # this is a callback which is invoked when check_in! is called
  def check_in
    self.in_at = DateTime.current
    halt "All components must be inventoried before check in"     unless check_in_components_inventoried?

    # TODO: move this up into the authorization layer
    #halt "In attendant must have the 'attendant' role"            unless in_attendant_has_proper_roles?
    #halt "In attendant can not check in equipment to themselves"  unless in_attendant_is_not_the_client?
  end

  def check_in_components_inventoried?
    ensure_presence(kit)
    return false unless check_in_inventory_record
    inventoried_component_ids = check_in_inventory_record.inventory_details.map(&:component_id)
    (inventoried_component_ids == kit.component_ids.sort)
  end

  # this is a callback which is invoked when check_out! is called
  def check_out
    self.out_at = DateTime.current
    halt "All components must be inventoried before check out"     unless check_out_components_inventoried?

    # TODO: move this up into the authorization layer
    # halt "Out attendant must have the 'attendant' role"            unless out_attendant_has_proper_roles?
    # halt "Out attendant can not check out equipment to themselves" unless out_attendant_is_not_the_client?
  end

  def check_out_components_inventoried?
    ensure_presence(kit)
    return false unless check_out_inventory_record
    inventoried_component_ids = check_out_inventory_record.inventory_details.map(&:component_id)
    (inventoried_component_ids == kit.component_ids.sort)
  end

  def client_is_disabled?
    ensure_presence(client)
    client.disabled?
  end

  def convert_to_datetime(thing)
    if thing.is_a? DateTime
      return thing
    elsif thing.is_a? String
      return Time.zone.parse(thing).to_datetime
    elsif thing.is_a? Time
      return thing.to_datetime
    end

    raise InvalidDateTimeFormatException.new("Incompatible class, expected DateTime, Time, or String, but got: #{ thing.class }")
  end

  def ensure_presence(attr)
    raise "attribute must be defined" unless attr
  end

  def client_is_suspended?
    ensure_presence(client)
    ensure_presence(starts_at)
    client.suspended?(starts_at)
  end

  def client_signed_all_covenants?
    ensure_presence(client)
    client.signed_all_covenants?
  end

  # TODO: move this up into the authorization layer
  # def in_attendant_has_proper_roles?
  #   ensure_presence(in_attendant)
  #   in_attendant.attendant?
  # end
  # def in_attendant_is_not_the_client?
  #   ensure_presence(client)
  #   ensure_presence(in_attendant)
  #   (in_attendant != client) || in_attendant.admin?
  # end

  def kit_available?
    ensure_presence(kit)
    kit.available?(starts_at, ends_at, self)
  end

  def kit_circulating?
    ensure_presence(kit)
    kit.circulating?
  end

  def kit_location_open_on_ends_at?
    ensure_presence(kit)
    ensure_presence(ends_at)
    location.open_on?(ends_at)
  end

  def kit_location_open_on_starts_at?
    ensure_presence(kit)
    ensure_presence(starts_at)
    location.open_on?(starts_at)
  end

  def kit_permissions_include?(client)
    ensure_presence(kit)
    ensure_presence(client)
    kit.permissions_include?(client)
  end

  def kit_requires_client_training?
    ensure_presence(kit)
    ensure_presence(client)
    kit.requires_client_training?(client)
  end

  # TODO: move this up into the authorization layer
  # def out_attendant_has_proper_roles?
  #   ensure_presence(out_attendant)
  #   out_attendant.attendant?
  # end
  # def out_attendant_is_not_the_client?
  #   ensure_presence(client)
  #   ensure_presence(out_attendant)
  #   (out_attendant != client) || out_attendant.admin?
  # end

  def ready_for_approval?
    approver && (((approver == User.system_user) && within_default_length?) || (approver.approver? && ends_at && client && kit && starts_at))
  end

  def starts_at_before_ends_at?
    ensure_presence(starts_at)
    ensure_presence(ends_at)
    (starts_at < ends_at)
  end

  def validate_approver_has_approver_role
    return unless approver
    unless approver_has_approval_role?
      errors.add(:approver, "must have 'approver' role.")
    end
  end

  def validate_check_in_components_inventoried
    return unless kit
    unless check_in_components_inventoried?
      errors[:base] << "All components must be inventoried at the time of check in"
    end
  end

  def validate_check_out_components_inventoried
    return unless kit
    unless check_out_components_inventoried?
      errors[:base] << "All components must be inventoried at the time of check out"
    end
  end

  def validate_client_is_not_disabled
    return unless client
    if client_is_disabled?
      errors.add(:client, "is disabled.")
    end
  end

  def validate_client_is_not_suspended
    return unless client && starts_at
    if client_is_suspended?
      errors.add(:client, "is suspended until #{ UserDecorator.decorate(client).suspended_until }.")
    end
  end

  def validate_client_has_permission
    return unless kit && client
    unless kit_permissions_include?(client)
      errors.add(:client, "does not have permission to check out this kit.")
    end
  end

  def validate_client_has_proper_training
    return unless kit
    if kit_requires_client_training?
      errors.add(:client, "does not have proper training for this kit.")
    end
  end

  def validate_client_signed_all_covenants
    return unless client
    unless client_signed_all_covenants?
      errors.add(:client, "has not signed all covenants.")
    end
  end

  def validate_kit_available
    return unless kit
    unless kit_available?
      errors.add(:starts_at, "kit is already loaned out for some (or all) of the reqested dates.")
    end
  end

  def validate_kit_circulating
    return unless kit
    unless kit_circulating?
      errors.add(:kit, "is not circulating. Choose another kit.")
    end
  end

  def validate_open_on_ends_at
    return unless kit && ends_at
    unless kit_location_open_on_ends_at?
      errors.add(:ends_at, "must be on a day with valid checkout hours")
    end
  end

  def validate_open_on_starts_at
    return unless kit && starts_at
    unless kit_location_open_on_starts_at?
      errors.add(:starts_at, "must be on a day with valid checkout hours")
    end
  end

  def validate_start_at_before_ends_at
    return unless starts_at && ends_at
    unless starts_at_before_ends_at?
      errors.add(:starts_at, "must come before the return date")
    end
  end

end

  # TODO: move these constraints up into the authorization layer
  # validates :in_attendant,      :associated => true,    :if     => :checked_in?
  # validates :in_attendant_id,   :presence   => true,    :if     => :checked_in?
  # validates :out_attendant,     :associated => true,    :if     => :checked_out?
  # validates :out_attendant_id,  :presence   => true,    :if     => :checked_out?
  # validate  :validate_in_attendant_has_proper_roles,    :if     => :checked_in?
  # validate  :validate_in_attendant_is_not_client,       :if     => :checked_in?
  # validate  :validate_out_attendant_has_proper_roles,   :if     => :checked_out?
  # validate  :validate_out_attendant_is_not_client,      :if     => :checked_out?

  # TODO: move this up into the authorization layer
  # def validate_in_attendant_has_proper_roles
  #   return unless in_attendant
  #   unless in_attendant_has_proper_roles?
  #     errors.add(:in_attendant, "must be an attendant or admin)")
  #   end
  # end
  # def validate_in_attendant_is_not_client
  #   return unless in_attendant
  #   unless in_attendant_is_not_the_client?
  #     errors.add(:in_attendant, "cannot check in items to themselves unless they are an admin")
  #   end
  # end
  # def validate_out_attendant_has_proper_roles
  #   return unless out_attendant
  #   unless out_attendant_has_proper_roles?
  #     errors.add(:out_attendant, "must be an attendant or admin")
  #   end
  # end
  # def validate_out_attendant_is_not_client
  #   return unless out_attendant && client
  #   unless out_attendant_is_not_the_client?
  #     errors.add(:out_attendant, "cannot check out items to themselves unless they are an admin")
  #   end
  # end
