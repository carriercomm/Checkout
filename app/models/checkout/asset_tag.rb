module Checkout
  class AssetTag < ActiveRecord::Base
    belongs_to :part
  end
end
