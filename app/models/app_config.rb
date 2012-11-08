class AppConfig < ActiveRecord::Base
  # there can be only one
  acts_as_singleton

  attr_accessible :default_checkout_length

  validates :default_checkout_length, numericality: { only_integer: true, greater_than: 0 }

end
