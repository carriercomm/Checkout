class AppConfig < ActiveRecord::Base
  # there can be only one
  acts_as_singleton

  attr_accessible :default_checkout_length
end
