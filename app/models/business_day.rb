class BusinessDay < ActiveRecord::Base

  ## Assoctions ##

  has_and_belongs_to_many :business_hours


  ## Mass-Assignable Attributes ##

  attr_accessible :index, :name

end
