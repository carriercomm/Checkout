class Kit < ActiveRecord::Base
  belongs_to :location
  has_many   :parts
  has_many   :models, :through => :parts
  has_many   :reservations
  has_many   :clients, :through => :reservations
  # has_and_belongs_to_many :groups

  def to_s
    name
  end

end
