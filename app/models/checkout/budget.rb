module Checkout
  class Budget < ActiveRecord::Base

    validates :number, :format     => { :with => /\d{2}-\d{4}/, :message => "Must follow format XX-XXXX" }
    validates :number, :presence   => true
    validates :number, :uniqueness => { :scope => :date_start }

    # TODO: add validations here for date_start, date_end
    # (e.g. date_start < date_end, must have date_start if date_end
    # and vice-versa)

    before_validation :strip_fields

    def display_date
      if !!date_start && !!date_end
        return "#{ date_start.year }-#{ date_end.year }"
      else
        return "Unknown"
      end
    end

    def to_s
      "#{ number } : #{ display_date } : #{ name }"
    end

    protected

    def strip_fields
      number.strip! unless number.blank?
      name.strip!   unless name.blank?
    end

  end
end
