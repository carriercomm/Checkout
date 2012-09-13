class Covenant < ActiveRecord::Base

  ## Associations ##

  has_many :covenant_signatures, :inverse_of => :covenant
  has_many :covenants, :through => :covenant_signatures

  ## Mass-assignable Attributes ##

  attr_accessible :accepted, :description, :name

end
