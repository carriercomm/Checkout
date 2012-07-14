class User < ActiveRecord::Base

  #
  # Macros
  #

  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise(:database_authenticatable, :lockable, :registerable,
         :recoverable, :rememberable, :timeoutable, :trackable,
         :validatable)


  #
  # Associations
  #

  has_many :reservations, :foreign_key => "client_id"
  has_many :approvals,    :foreign_key => "approver_id",      :class_name => 'Reservation'
  has_many :out_assists,  :foreign_key => "out_assistant_id", :class_name => 'Reservation'
  has_many :in_assists,   :foreign_key => "in_assistant_id",  :class_name => 'Reservation'


  #
  # Mass-assignable Attributes
  #
  
  attr_accessible(:email,
                  :login,
                  :password,
                  :password_confirmation,
                  :remember_me,
                  :username)
  

  #
  # Virtual Attributes
  #

  # For authenticating by either username or email. This is in addition
  # to a real persisted field like 'username'
  attr_accessor :login


  #
  # Static Methods
  #

  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    login = conditions.delete(:login)
    where(conditions).where(["lower(username) = :value OR lower(email) = :value", { :value => login.strip.downcase }]).first
  end


  #
  # Instance Methods
  #

  def to_s
    username
  end

end
