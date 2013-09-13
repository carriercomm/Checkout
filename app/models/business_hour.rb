class BusinessHour < ActiveRecord::Base

  ## Associations ##

  belongs_to :location, :inverse_of => :business_hours
  has_and_belongs_to_many :business_days, :order => "index ASC"


  ## Validations ##

  # TODO: validate with overlap detection for business hours

  validates :location,     :presence => true
  validates :open_hour,    :presence => true
  validates :open_hour,    :numericality => { :only_integer => true,
                                              :greater_than_or_equal_to => 0,
                                              :less_than => 24 }
  validates :open_minute,  :presence => true
  validates :open_minute,  :numericality => { :only_integer => true,
                                              :greater_than_or_equal_to => 0,
                                              :less_than => 60 }
  validates :close_hour,   :presence => true
  validates :close_hour,   :numericality => { :only_integer => true,
                                              :greater_than_or_equal_to => 0,
                                              :less_than => 24 }
  validates :close_minute, :presence => true
  validates :close_minute, :numericality => { :only_integer => true,
                                              :greater_than_or_equal_to => 0,
                                              :less_than => 60 }
  validate :should_have_at_least_one_business_day
  validates :location_id,  :uniqueness => { :scope   => [:open_hour, :open_minute],
                                            :message => "You can't have duplicate open hours. Add additional days to the existing business hours instead." }


  ## Mass-assignable attributes ##

  attr_accessible(:location_id,
                  :business_day_ids,
                  :open_hour,
                  :open_minute,
                  :close_hour,
                  :close_minute)


  ## Class methods ##

  def self.hours_for_select
    (0..23).collect { |i| ["%02d" % i, i]}
  end

  def self.minutes_for_select
    [0, 15, 30, 45].collect { |i| ["%02d" % i, i] }
  end


  ## Instance methods ##

  # returns an array of dates representing the days with
  # open business hours between now and days_out
  def open_occurrences(days_out = 90, date_start = Time.zone.now)
    schedule =  IceCube::Schedule.new(date_start)
    date_end = date_start + days_out.days

    # add a recurrence for each business day
    business_days.each do |bd|
      day = bd.name.downcase.to_sym
      schedule.add_recurrence_rule IceCube::Rule.weekly.day(day)
    end

    return schedule.occurrences(date_end)
  end

  def required_attrs_blank?
    return (open_hour.blank? || open_minute.blank? || close_hour.blank? || close_minute.blank?)
  end

  def should_have_at_least_one_business_day
    if business_days.empty?
      errors[:base] << "Should have at least one open day"
    end
  end

end
