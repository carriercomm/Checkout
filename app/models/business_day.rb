class BusinessDay < ActiveRecord::Base
  has_and_belongs_to_many :business_hours
  attr_accessible :index, :name
end
