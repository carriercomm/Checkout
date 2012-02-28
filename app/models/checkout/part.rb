module Checkout
  class Part < ActiveRecord::Base

    has_many   :asset_tags
    belongs_to :kit
    belongs_to :model

  end
end
