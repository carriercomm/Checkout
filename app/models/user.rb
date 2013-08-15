class User < ActiveRecord::Base

  ## Macros ##

  rolify
  strip_attributes :only => [:suspended_until]
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :registerable, :timeoutable and :omniauthable
  devise(:database_authenticatable, :lockable, :recoverable, :rememberable,
         :timeoutable, :trackable, :validatable, :registerable)


  ## Associations ##

  has_many :approvals,           :foreign_key => "approver_id", :class_name => 'Loan', :inverse_of => :approver
  has_many :component_models,    :through => :trainings
  has_many :covenant_signatures, :inverse_of => :user
  has_many :covenants,           :through => :covenant_signatures
  has_many :groups,              :through => :memberships
  has_many :in_assists,          :foreign_key => "in_attendant_id", :class_name => 'Loan', :inverse_of => :in_attendant
  has_many :inventory_records,   :foreign_key => "attendant_id"
  has_many :loans,               :foreign_key => "client_id", :inverse_of => :client do
    def build_from_component_model_id(component_model_id)
      component_model = ComponentModel.circulating.includes(:kits => :location).find(component_model_id)
      build(:component_model => component_model)
    end
  end
  has_many :memberships,         :inverse_of => :user
  has_many :out_assists,         :foreign_key => "out_attendant_id", :class_name => 'Loan', :inverse_of => :out_attendant
  has_many :trainings,           :inverse_of => :user, :dependent => :destroy


  ## Mass-assignable Attributes ##

  attr_accessible(:email,
                  :first_name,
                  :last_name,
                  :login,
                  :password,
                  :password_confirmation,
                  :remember_me,
                  :username)

  accepts_nested_attributes_for(:inventory_records,
                                :reject_if => proc { |attributes| attributes['component_id'].blank? || attributes['inventory_status_id'].blank? },
                                :allow_destroy=> false)

  accepts_nested_attributes_for(:memberships,
                                :reject_if => proc { |attributes| attributes['group_id'].blank? },
                                :allow_destroy=> true)

  accepts_nested_attributes_for(:trainings,
                                :reject_if => proc { |attributes| attributes['component_model_id'].blank? },
                                :allow_destroy=> true)

  ## Virtual Attributes ##

  # For authenticating by either username or email. This is in addition
  # to a real persisted field like 'username'
  attr_accessor :login


  ## Validations ##

  validates :username, :email, :presence => true


  ## Callbacks ##

  before_save :downcase_username


  ## Named Scopes ##

  default_scope where("users.username <> 'system'")


  ## Static Methods ##

  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    login = conditions.delete(:login)
    where(conditions).where(["LOWER(username) = :value OR LOWER(email) = :value", { :value => login.strip.downcase }]).first
  end

  # returns an AREL which filters out users who are already in a
  # specific group (specified by the group id)
  def self.not_in_group(group_id)
    group = Group.find(group_id)
    return self if group.nil?

    user_ids = group.users.map(&:id)
    return self if user_ids.empty?

    where("users.id NOT IN (?)", user_ids)
  end

  def self.system_user
    self.unscoped.find_by_username('system')
  end

  def self.username_search(query)
    where("LOWER(users.username) LIKE ?", "%#{ query.downcase }%")
      .order("users.username ASC")
  end

  def self.search(query)
    where("LOWER(users.username) LIKE ? OR LOWER(users.first_name) LIKE ? OR LOWER(users.last_name) LIKE ?", "%#{ query.downcase }%", "%#{ query.downcase }%", "%#{ query.downcase }%")
      .order("users.username ASC")
  end


  ## Instance Methods ##

  def admin?
    has_role?(:admin)
  end

  def approver?
    has_role?(:approver)
  end

  def attendant?
    has_role?(:attendant) || admin?
  end

  def can_see_entire_circulating_inventory?
    Settings.clients_can_see_equipment_outside_their_groups || admin?
  end

  def disabled?
    disabled == true
  end

  def downcase_username
    username.downcase!
  end

  def new_inventory_records(kit)
    components = kit.is_a?(Draper::Base) ? kit.model.components : kit.components
    components.map do |c|
      ir = InventoryRecord.new
      ir.attendant = self
      ir.component = c
      ir
    end
  end

  def signed_all_covenants?
    covenant_signatures.count == Covenant.count
  end

  def supervisor?(group)
    !memberships.where(group_id: group.id, supervisor: true).empty?
  end

  def suspended?(reference_date = Date.today)
    !suspended_until.nil? && suspended_until.to_date > reference_date.to_date
  end

  def to_param
    "#{ id } #{ username }".parameterize
  end

  def to_s
    username
  end

end
