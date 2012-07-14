class Brand < ActiveRecord::Base

  #
  # Associations
  #
  
  has_many :models


  #
  # Validations
  #

  validates :name, :presence   => true
  validates :name, :uniqueness => true


  #
  # Mass-assignable Attributes
  #

  attr_accessible :name


  #
  # Class Methods
  #

  def self.having_tombstoned_kits
    joins(:models => :kits).where("kits.tombstoned = ?", true).uniq
  end

  def self.not_having_checkoutable_kits
    joins(:models => :kits).where("kits.checkoutable = ?", false).uniq
  end

  def self.having_checkoutable_kits
    joins(:models => :kits).where("kits.tombstoned = ? AND kits.checkoutable = ?", false, true).uniq
  end


  #
  # Instance Methods
  #

  def to_param
    "#{ id } #{ name }".parameterize
  end

  def to_s
    name
  end

end
