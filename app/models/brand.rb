class Brand < ActiveRecord::Base
  has_many :models

  default_scope { order(:name) }

  def to_s
    name
  end

end
