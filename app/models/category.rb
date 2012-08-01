class Category < ActiveRecord::Base

  #
  # Associations
  #

  has_and_belongs_to_many :models

  #
  # Mass-assignable Attributes
  #

  validates :name, :presence => true
  validates :name, :uniqueness => true


  #
  # Mass-assignable Attributes
  #

  attr_accessible :name, :description

  def to_s
    name
  end

end
