class Brand < ActiveRecord::Base
  has_many :models

  attr_accessible :name

  default_scope order("brands.name ASC")

  def self.tombstoned
    joins(:models => {:parts => :kit }).where("kits.tombstoned = ?", true).uniq
  end

  def self.not_checkoutable
    joins(:models => {:parts => :kit }).where("kits.checkoutable = ?", false).uniq
  end

  def self.checkoutable
    joins(:models => {:parts => :kit }).where("kits.tombstoned = ? AND kits.checkoutable = ?", false, true).uniq
  end

  def to_s
    name
  end

end
