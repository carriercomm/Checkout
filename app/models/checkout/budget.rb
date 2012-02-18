module Checkout
  class Budget < ActiveRecord::Base

    validates :number, :format     => { :with => /\d{2}-\d{4}/, :message => "Must follow format XX-XXXX" }
    validates :number, :presence   => true
    validates :number, :uniqueness => true

    before_validation :strip_fields

    protected

    def strip_fields
      number.strip! unless number.empty?
      name.strip!   unless name.empty?
    end

  end
end
