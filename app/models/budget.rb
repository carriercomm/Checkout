class Budget < ActiveRecord::Base

  ## Macros ##

  strip_attributes


  ## Associations ##

  has_many  :kits, :inverse_of => :budget


  ## Validations ##

  validates :number, :format     => { :with => /\d{2}-\d{4}/, :message => "Must follow format XX-XXXX" }
  validates :number, :presence   => true
  validates :number, :uniqueness => { :scope => :date_start }

  # TODO: add validations here for date_start, date_end
  # (e.g. date_start < date_end, must have date_start if date_end
  # and vice-versa)


  ## Mass-assignable Attributes ##

  attr_accessible(:name,
                  :number,
                  :date_start,
                  :date_end)


  ## Static Methods ##

  def self.active
    where("? BETWEEN budgets.date_start AND budgets.date_end", Time.zone.now).order("budgets.number")
  end

  def self.options_map
    order("date_start DESC, number ASC").all.map { |b| [b.to_s, b.id] }
  end


  ## Instance Methods ##

  def to_param
    "#{ id } #{ name } #{ number }".parameterize
  end

  # moved to the decorator
  # def to_s
  #   "#{ number } #{ name } (#{ display_date.rjust(9) })"
  # end

end
