module Checkout
  class Model < ActiveRecord::Base

    belongs_to :maker
    has_many   :parts
    has_many   :kits, :through => :parts

    has_and_belongs_to_many :categories

  end
end
