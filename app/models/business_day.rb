class BusinessDay < ActiveRecord::Base

  ## Macros ##

  resourcify


  ## Assoctions ##

  has_and_belongs_to_many :business_hours


  ## Mass-Assignable Attributes ##

  attr_accessible :index, :name

end
