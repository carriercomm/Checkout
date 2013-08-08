class Budget < ActiveRecord::Base

  ## Macros ##

  strip_attributes


  ## Associations ##

  has_many  :kits, :inverse_of => :budget


  ## Validations ##

  validates :number, :format     => { :with => /\d{2}-\d{4}/, :message => "Must follow format XX-XXXX" }
  validates :number, :presence   => true
  validates :number, :uniqueness => { :scope => :starts_at }

  # TODO: add validations here for starts_at, ends_at
  # (e.g. starts_at < ends_at, must have starts_at if ends_at
  # and vice-versa)


  ## Mass-assignable Attributes ##

  attr_accessible(:name,
                  :number,
                  :starts_at,
                  :ends_at)


  ## Static Methods ##

  def self.active
    where("? BETWEEN budgets.starts_at AND budgets.ends_at", Time.zone.now).order("budgets.number")
  end

  def self.options_map
    order("budgets.starts_at DESC, budgets.number ASC").all.map { |b| [b.to_s, b.id] }
  end


  ## Instance Methods ##

  def to_param
    "#{ id } #{ name } #{ number }".parameterize
  end

end
