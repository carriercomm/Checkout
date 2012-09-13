class CovenantSignature < ActiveRecord::Base

  ## Associations ##

  belongs_to :user
  belongs_to :covenant

  ## Mass-assignable Attributes ##

  attr_accessible :covenant, :user
  
end
